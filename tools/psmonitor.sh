IFS=$'\n' # ippsec video solidstate 19:49

op=(pso -eo command)

while true; do
    np=$(ps -eo command)
    diff <(echo "$op") <(echo "$np")
    sleep .2
    op=$np
done