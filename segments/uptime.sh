# Prints the uptime.

run_segment() {
    uptime | sed -e "s/.* up *//" -e "s/ *days, */d/" -e "s/:/h/" -e "s/,.*/m/"
    return 0
}
