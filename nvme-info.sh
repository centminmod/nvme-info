#!/bin/bash
###################################################################
# nvme drive info by George Liu
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

# Get the list of all NVMe drives
drives=$(nvme list -o json | jq -r '.Devices[].DevicePath')

# Variable to hold the JSON output
output_json="["

# Loop over each drive
for drive in $drives; do
    # Get drive information
    drive_info=$(nvme list -o json | jq -r ".Devices[] | select(.DevicePath==\"$drive\")")
    model=$(echo "$drive_info" | jq -r '.ModelNumber')
    firmware=$(echo "$drive_info" | jq -r '.Firmware')
    size=$(echo "$drive_info" | jq -r '.PhysicalSize')
    size=$(format_size $size)

    # Get SMART log
    smart=$(nvme smart-log $drive -o json)
    temperature=$(echo "$smart" | jq -r '.temperature' | awk '{print $1 - 273.15}')
    available_spare=$(echo "$smart" | jq -r '.avail_spare')
    percentage_used=$(echo "$smart" | jq -r '.percent_used')
    power_on_hours=$(echo "$smart" | jq -r '.power_on_hours')
    power_on_days=$(echo "$power_on_hours/24" | bc)
    power_on_hours_remainder=$(echo "$power_on_hours%24" | bc)
    data_units_read=$(echo "$smart" | jq -r '.data_units_read')
    data_units_written=$(echo "$smart" | jq -r '.data_units_written')
    host_read_commands=$(echo "$smart" | jq -r '.host_read_commands')
    host_write_commands=$(echo "$smart" | jq -r '.host_write_commands')
    controller_busy_time=$(echo "$smart" | jq -r '.controller_busy_time')
    power_cycles=$(echo "$smart" | jq -r '.power_cycles')
    data_units_read_size=$(format_size $(bc <<< "scale=2; $data_units_read*1000*512"))
    data_units_written_size=$(format_size $(bc <<< "scale=2; $data_units_written*1000*512"))

    # Generate the JSON representation of the data
    drive_json=$(jq -n \
                  --arg drive "$drive" \
                  --arg model "$model" \
                  --arg firmware "$firmware" \
                  --arg size "$size" \
                  --argjson temperature "$temperature" \
                  --argjson available_spare "$available_spare" \
                  --argjson percentage_used "$percentage_used" \
                  --argjson power_on_days "$power_on_days" \
                  --argjson power_on_hours_remainder "$power_on_hours_remainder" \
                  --argjson data_units_read "$data_units_read" \
                  --argjson data_units_written "$data_units_written" \
                  --argjson host_read_commands "$host_read_commands" \
                  --argjson host_write_commands "$host_write_commands" \
                  --argjson controller_busy_time "$controller_busy_time" \
                  --argjson power_cycles "$power_cycles" \
                  --arg data_units_read_size "$data_units_read_size" \
                  --arg data_units_written_size "$data_units_written_size" \
                  '{drive: $drive, model: $model, firmware: $firmware, size: $size, temperature: $temperature, available_spare: $available_spare, percentage_used: $percentage_used, powered_on_time: {days: $power_on_days, hours: $power_on_hours_remainder}, data_units_read: {units: $data_units_read, size: $data_units_read_size}, data_units_written: {units: $data_units_written, size: $data_units_written_size}, host_read_commands: $host_read_commands, host_write_commands: $host_write_commands, controller_busy_time: $controller_busy_time, power_cycles: $power_cycles}')
    output_json+="$drive_json,"

    if [ "$OUTPUT" == "normal" ]; then
        # Normal output
        echo "Drive: $drive"
        echo "Model: $model"
        echo "Firmware: $firmware"
        echo "Size: $size"
        echo "Temperature: $temperature C"
        echo "Available Spare: $available_spare%"
        echo "Percentage Used: $percentage_used%"
        echo "Powered On Time: $power_on_days days $power_on_hours_remainder hours"
        echo "Data Units Read: $data_units_read ($data_units_read_size)"
        echo "Data Units Written: $data_units_written ($data_units_written_size)"
        echo "Host Read Commands: $host_read_commands"
        echo "Host Write Commands: $host_write_commands"
        echo "Controller Busy Time: $controller_busy_time"
        echo "Power Cycles: $power_cycles"
        echo "-----"
    fi
done

# Remove the trailing comma and close the JSON array
output_json=${output_json%?}
output_json+="]"

if [ "$OUTPUT" == "json" ]; then
    echo "$output_json"
fi
