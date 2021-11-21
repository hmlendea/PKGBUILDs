#!/bin/sh

APP_PATH="${1}"
APP_ARGS="${@:2}"

GPU_TO_USE="Intel"

# Check that bumblee is installed

if [ ! -f "/usr/bin/bumblebeed" ]; then
    echo "ERROR: bumblebee is not installed!"
    exit 1
fi

# Detect battery state

if [ -d "/sys/module/battery" ] \
&& [ -d "/sys/class/power_supply/BAT0" ] \
&& [ -d "/proc/acpi/button/lid" ]; then
    BATTERY_STATE=$(cat "/sys/class/power_supply/BAT0/status")

    echo "Battery state is '${BATTERY_STATE}'"

    if [ "${BATTERY_STATE}" = "Charging" ] || [ "${BATTERY_STATE}" = "Full" ] || [ "${BATTERY_STATE}" = "Unknown" ]; then
        GPU_TO_USE="Nvidia"
    fi
else
    echo "ERROR: No battery detected!"
    echo "This script only works on laptops."

    exit 2
fi

# Print info

echo "Launching the application through the ${GPU_TO_USE} GPU..."
echo " - Application path: ${APP_PATH}"
echo " - Application args: ${APP_ARGS}"

# Execute bin

if [ "${GPU_TO_USE}" = "Intel" ]; then
    "${APP_PATH}" ${APP_ARGS}
elif [ "$GPU_TO_USE" = "Nvidia" ]; then
    COMPRESSION_METHOD="jpeg" # yuv has similar results

    export vblank_mode=0
    export VGL_READBACK=pbo

    echo "Framelimit (vblank_mode): ${vblank_mode}"
    echo "VGL_READBACK: ${VGL_READBACK}"
    echo "Compression method: ${COMPRESSION_METHOD}"

    optirun -c "${COMPRESSION_METHOD}" -b primus "${APP_PATH}" ${APP_ARGS}
fi
