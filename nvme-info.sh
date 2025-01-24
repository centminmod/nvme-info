#!/bin/bash
###################################################################
# Storage info script for NVMe and SSD drives
###################################################################

# Function to format the data units read/written
function format_size {
    local units=("B" "KB" "MB" "GB" "TB" "PB")
    local size=$1
    local unit_count=0

    while (( $(bc <<< "$size >= 1024") ))
    do
        size=$(bc <<< "scale=2; $size/1024")
        ((unit_count++))
    done

    echo "$size ${units[$unit_count]}"
}

# Function to check and install required packages
function check_packages {
    local packages=("nvme-cli" "jq" "bc" "smartmontools")
    local need_install=false

    for pkg in "${packages[@]}"; do
        if ! rpm -q "$pkg" &>/dev/null; then
            echo "Installing $pkg..."
            yum -y -q install "$pkg"
            need_install=true
        fi
    done

    if [ "$need_install" = true ]; then
        echo "Required packages have been installed."
    fi
}

# Function to process SMART drive info
function process_smart_drive {
    local drive=$1
    local smart_info
    smart_info=$(smartctl -a "$drive" -j)

    # Extract model and basic info
    local model
    local serial
    local firmware
    local size
    local temperature
    local power_on_hours
    local power_cycles
    local total_written_gib
    
    model=$(echo "$smart_info" | jq -r '.model_name // .model_family')
    total_written_gib=$(echo "$smart_info" | jq -r '.ata_smart_attributes.table[] | select(.name=="Lifetime_Writes_GiB") | .raw.value')
    serial=$(echo "$smart_info" | jq -r '.serial_number')
    firmware=$(echo "$smart_info" | jq -r '.firmware_version')
    size=$(echo "$smart_info" | jq -r '.user_capacity.bytes')
    temperature=$(echo "$smart_info" | jq -r '.temperature.current')
    power_on_hours=$(echo "$smart_info" | jq -r '.power_on_time.hours')
    power_cycles=$(echo "$smart_info" | jq -r '.power_cycle_count')

    if [ "$OUTPUT" == "normal" ]; then
        echo "Drive: $drive"
        echo "Model: $model"
        echo "Serial: $serial"
        echo "Firmware: $firmware"
        echo "Size: $(format_size "$size")"
        [ ! -z "$temperature" ] && echo "Temperature: $temperature C"
        [ ! -z "$power_on_hours" ] && echo "Power On Hours: $power_on_hours"
        [ ! -z "$power_cycles" ] && echo "Power Cycles: $power_cycles"
        [ ! -z "$total_written_gib" ] && echo "Total Written: $total_written_gib GiB"
        echo "-----"
    fi

    # Add to JSON output
    drive_json=$(jq -n \
        --arg drive "$drive" \
        --arg model "$model" \
        --arg serial "$serial" \
        --arg firmware "$firmware" \
        --arg size "$(format_size "$size")" \
        --argjson temperature "$temperature" \
        --argjson power_on_hours "$power_on_hours" \
        --argjson power_cycles "$power_cycles" \
        '{drive: $drive, model: $model, serial: $serial, firmware: $firmware, size: $size, temperature: $temperature, power_on_hours: $power_on_hours, power_cycles: $power_cycles, type: "sata_ssd"}')
    output_json+="$drive_json,"
}

# Check and install required packages
check_packages

# Output format
OUTPUT="normal"

while getopts ":o:" opt; do
  case ${opt} in
    o )
      OUTPUT=$OPTARG
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      ;;
  esac
done
shift $((OPTIND -1))

# Variable to hold the JSON output
output_json="["

# Process NVMe drives
if command -v nvme &>/dev/null; then
    drives=$(nvme list -o json | jq -r '.Devices[].DevicePath')
    for drive in $drives; do
        drive_info=$(nvme list -o json | jq -r ".Devices[] | select(.DevicePath==\"$drive\")")
        model=$(echo "$drive_info" | jq -r '.ModelNumber')
        firmware=$(echo "$drive_info" | jq -r '.Firmware')
        size=$(echo "$drive_info" | jq -r '.PhysicalSize')
        size=$(format_size "$size")

        smart=$(nvme smart-log "$drive" -o json)
        temperature=$(echo "$smart" | jq -r '.temperature' | awk '{print $1 - 273.15}')
        available_spare=$(echo "$smart" | jq -r '.avail_spare')
        percentage_used=$(echo "$smart" | jq -r '.percent_used')
        power_on_hours=$(echo "$smart" | jq -r '.power_on_hours')
        power_cycles=$(echo "$smart" | jq -r '.power_cycles')
        data_units_read_size=$(format_size $(bc <<< "scale=2; $(echo "$smart" | jq -r '.data_units_read')*1000*512"))
        data_units_written_size=$(format_size $(bc <<< "scale=2; $(echo "$smart" | jq -r '.data_units_written')*1000*512"))
        data_written_gib=$(bc <<< "scale=2; $(echo "$smart" | jq -r '.data_units_written')*1000*512/1024/1024/1024")

        if [ "$OUTPUT" == "normal" ]; then
            echo "Drive: $drive (NVMe)"
            echo "Model: $model"
            echo "Firmware: $firmware"
            echo "Size: $size"
            echo "Temperature: $temperature C"
            echo "Available Spare: $available_spare%"
            echo "Percentage Used: $percentage_used%"
            echo "Power On Hours: $power_on_hours"
            echo "Data Read: $data_units_read_size"
            echo "Data Written: $data_units_written_size"
            echo "Total Written: $data_written_gib GiB"
            echo "Power Cycles: $power_cycles"
            echo "-----"
        fi

        drive_json=$(jq -n \
            --arg drive "$drive" \
            --arg model "$model" \
            --arg firmware "$firmware" \
            --arg size "$size" \
            --argjson temperature "$temperature" \
            --argjson available_spare "$available_spare" \
            --argjson percentage_used "$percentage_used" \
            --argjson power_on_hours "$power_on_hours" \
            --arg data_read "$data_units_read_size" \
            --arg data_written "$data_units_written_size" \
            --argjson power_cycles "$power_cycles" \
            '{drive: $drive, model: $model, firmware: $firmware, size: $size, temperature: $temperature, available_spare: $available_spare, percentage_used: $percentage_used, power_on_hours: $power_on_hours, data_read: $data_read, data_written: $data_written, power_cycles: $power_cycles, type: "nvme"}')
        output_json+="$drive_json,"
    done
fi

# Process SATA SSDs
for drive in $(lsblk -d -o name,type | grep 'disk' | awk '{print $1}'); do
    if [[ ! "$drive" =~ ^nvme ]]; then
        drive="/dev/$drive"
        if smartctl -i "$drive" | grep -qi "Solid State Device"; then
            process_smart_drive "$drive"
        fi
    fi
done

# Remove the trailing comma and close the JSON array
output_json=${output_json%?}
output_json+="]"

if [ "$OUTPUT" == "json" ]; then
    echo "$output_json"
fi