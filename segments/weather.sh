# Prints the current weather in Celsius, Fahrenheits or lord Kelvins. The forecast is cached and updated with a period of $update_period.

# The update period in seconds.
update_period=600

# configure ansiweather here
export ANSIWEATHERRC="${TMUX_POWERLINE_DIR_HOME}/config/ansiweatherrc"

run_segment() {
	local tmp_file="${TMUX_POWERLINE_DIR_TEMPORARY}/weather.txt"
	local weather
	weather=$(__get_weather)
	if [ -n "$weather" ]; then
		echo "$weather"
	fi
}

__get_weather() {
	output=""
	if [ -f "$tmp_file" ]; then
		if shell_is_osx || shell_is_bsd; then
			last_update=$(stat -f "%m" ${tmp_file})
		elif shell_is_linux; then
			last_update=$(stat -c "%Y" ${tmp_file})
		fi
		time_now=$(date +%s)

		up_to_date=$(echo "(${time_now}-${last_update}) < ${update_period}" | bc)
		if [ "$up_to_date" -eq 1 ]; then
			__read_tmp_file
		fi
	fi

	if [ -z "$output" ]; then
		weather_data=$(ansiweather)
		if [ "$?" -eq "0" ]; then
			output="$weather_data"
		elif [ -f "${tmp_file}" ]; then
			__read_tmp_file
		fi
	fi

	if [ -n "$output" ]; then
		echo "${output}" | tee "${tmp_file}"
	fi
}

__read_tmp_file() {
	if [ ! -f "$tmp_file" ]; then
		return
	fi
	cat "${tmp_file}"
	exit
}
