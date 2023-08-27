#!/usr/bin/env bash

# initialize empty arrays
template_names=()
template_files=()
template_paths=()
template_parameters=()

# get the base sha for the diff
BASE_SHA=$(git rev-parse "origin/${GITHUB_BASE_REF:-${GITHUB_REF_NAME}^}")
# loop over changed bicep files but ignore deleted files
while IFS= read -r bicep; do

    # ensure clean bicepparam variable
    bicepparam=""
    # create variables for some checks
    filename=$(basename "${bicep}")
    foldername="$(basename "$(dirname "${bicep}")")"
    bicep_path="$(dirname "${bicep}")"

    # skip empty filename
    [[ -z "${filename}" ]] && continue

    # make sure the folder is not already in the array
    [[ "${template_paths[*]}" = *"${bicep_path}"* ]] \
        && echo "skipping ${bicep_path}" \
        && continue

    # ensure that changes to a .bicepparameter file get validated
    if [[ -f "${bicep_path}/main.${GITHUB_BASE_REF:-${GITHUB_REF_NAME}}.bicepparam" ]]; then
        # echo "found parameter file for ${foldername}"
        filename="main.bicep"
        bicepparam="main.${GITHUB_BASE_REF:-${GITHUB_REF_NAME}}.bicepparam"
    elif [[ -f "${bicep_path}/main.bicepparam" ]]; then
        # echo "found default parameter file for ${foldername}"
        filename="main.bicep"
        bicepparam="main.bicepparam"
    else
        echo "found no fitting bicepparam file for ${foldername}"
    fi

    # add current item to the arrays
    echo "adding ${foldername} to the matrix"
    template_names+=("${foldername}")
    template_files+=("main.bicep")
    template_paths+=("${bicep_path}")
    template_parameters+=("${bicepparam}")

done < <(git diff --name-only --diff-filter=d "${BASE_SHA}" -- 'azure/*/main.*bicep*' | xargs -0)

# function to create a json from the collected arrays
createJson() {
    printf "["
    for ((i = 0; i < ${#template_files[@]}; i++)); do
        printf "{"
        printf "\"name\":\"%s\"," "${template_names[${i}]}"
        printf "\"path\":\"%s\"," "${template_paths[${i}]}"
        printf "\"bicep\":\"%s\"," "${template_files[${i}]}"
        printf "\"bicepparams\":\"%s\"" "${template_parameters[${i}]}"
        printf "}"
        # check if we are not at the end of the array
        if [[ $i -lt $((${#template_files[@]} - 1)) ]]; then
            printf ","
        fi
    done
    printf "]"
}

# create the matrix json
matrix=$(createJson | jq -c '{include: [.[]| {name: .name, path: .path, template: .bicep, parameters: .bicepparams}]}')

# print the matrix json
printf "\ncreated matrix:\n%s" "$(echo "${matrix}" | jq)"

# create output variable
printf "matrix=%s\n" "${matrix}" >>"${GITHUB_OUTPUT}"
