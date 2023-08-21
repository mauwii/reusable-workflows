#!/usr/bin/env bash

name=()
template_files=()
template_paths=()
template_parameters=()

# loop over changed bicep files but ignore deleted files
while IFS= read -r bicep; do
    # create variables for some checks
    filename=$(basename "${bicep%.bicep}")
    foldername="$(basename "$(dirname "${bicep}")")"
    bicep_path="$(dirname "${bicep}")"
    # check if the bicep file is named like the folder
    if [[ "${foldername}" = "${filename}" ]]; then
        name+=("${filename}")
        template_files+=("${filename}.bicep")
        template_paths+=("$(dirname "${bicep}")")
        # check if there is a bicepparam file for the current branch
        if [[ -f "${bicep_path}/${filename}.${GITHUB_REF_NAME}.bicepparam" ]]; then
            template_parameters+=("${filename}.${GITHUB_REF_NAME}.bicepparam")
        # check if there is a general bicepparam file
        elif [[ -f "${bicep_path}/${filename}.bicepparam}" ]]; then
            template_parameters+=("${filename}.bicepparam}")
        # if no bicepparams where found add null to the array
        else
            # echo "No parameter file found for ${filename}"
            template_parameters+=("$null")
        fi
    fi
done < <(git diff --name-only --diff-filter=d "${GITHUB_BASE_REF:-${GITHUB_REF_NAME}^}" "${GITHUB_HEAD_REF:-${GITHUB_REF_NAME}}" -- '*.bicep' | xargs -0)

# function to create a json from the collected arrays
createJson() {
    printf "["
    # for i in "${!template_files[@]}"; do
    for ((i = 0; i < ${#template_files[@]}; i++)); do
        printf "{\"name\":\"%s\",\"path\":\"%s\",\"bicep\":\"%s\",\"bicepparams\":\"%s\"}" "${name[${i}]}" "${template_paths[${i}]}" "${template_files[${i}]}" "${template_parameters[${i}]}"
        # check if we are not at the end of the array
        if [[ $i -lt $((${#template_files[@]} - 1)) ]]; then
            printf ","
        fi
    done
    printf "]"
}

# matrix=$(createJson | jq -c '{include:[.[]| {bicepdir: .path, template: .bicep, parameter: .bicepparams}]}')
matrix=$(createJson | jq -c '{include: [.[]| {name: .name, path: .path, template: .bicep, parameter: .bicepparams}]}')

printf "matrix=%s\n" "${matrix}" >>"${GITHUB_OUTPUT}"
