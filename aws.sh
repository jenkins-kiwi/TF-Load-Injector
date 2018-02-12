#!/usr/bin/env bash
export PROJECT_ROOT="$(git rev-parse --show-toplevel)"
# [ ! -z "$PROJECT_ROOT" ] || export PROJECT_ROOT="/var/lib/jenkins/tf-load-injectors"

# bash ~/topfan/aws.sh ${MAX_INSTANCE} ${INSTANCE_TYPE} ${REQUESTER}  ${CREATOR} ${TICKET_ID} ${SECURITY_CHECK}
# export MAX_INSTANCE=1 INSTANCE_TYPE=t2.micro REQUESTER=Ankit CREATOR=harry TICKET_ID=12 SECURITY_CHECK=welcome OWNER=TopFan

#export MAX_INSTANCE INSTANCE_TYPE REQUESTER CREATOR TICKET_ID SECURITY_CHECK OWNER
#PROJECT_ROOT="/var/lib/jenkins/topfan"
source /var/lib/jenkins/testkey
source ${PROJECT_ROOT}/varfile
TF_MODE=${1}

terraform_run() {
  [[ "${TF_MODE}" == "plan" ]] && exit 0

  if [[ "${TF_RUN_YES}" != "yes" ]]; then
    echo; read -e -p "Are you happy with this plan (yes/no)? " TF_RUN_YES
    [[ "${TF_RUN_YES}" != "yes" ]] && exit 0
  fi

  echo
  echo "RUN: Applying Terraform with state file ${STATE_FILE}"

  if [[ "${TF_MODE}" == "destroy" ]]; then
    $TERRAFORM destroy -force -state="${STATE_FILE}"
    echo "return_val: ${return_val}"
    return_val=$?
    [[ ${return_val} -ne 0 ]] && \
      echo -e "${RED}WARNING: Terraform plan not applied successfully.${NC}" >&2 && \
      exit 1
  else
    $TERRAFORM apply -state="${STATE_FILE}" -input=false -auto-approve
    ret_val=$?
    echo "ret_val: ${ret_val}"

    [[ ${ret_val} -ne  0 ]] && \
      echo -e "${RED}WARNING: Terraform plan not applied successfully.${NC}" >&2 && \
      exit 1
  fi
}

terraform_execute(){
  cd ${PROJECT_ROOT}/${TF_DIRECTORY}
  export STATE_FILE=${PROJECT_ROOT}/state/terraform.tfstate
  export STATE_BKF_FILE=${STATE_FILE}.backup
  if [[ ! -d ${PROJECT_ROOT}/${TF_DIRECTORY}/.terraform/plugins  ]]; then
    ${TERRAFORM} init
  fi
  if [[ ${TF_MODE} == destroy ]]; then
    echo "Created Infra state Backup"
    cp ${STATE_FILE} ${STATE_BKF_FILE}
    echo "Destroying terraform code : ${PROJECT_NAME}"
    ${TERRAFORM} plan -destroy -state="${STATE_FILE}" -detailed-exitcode
    TF_RETVAL=${?}
  else
    echo "Executing Plan ${PROJECT_NAME}"
    ${TERRAFORM} plan -state=${STATE_FILE} -detailed-exitcode
    TF_RETVAL=${?}
  fi
  case ${TF_RETVAL} in
    0)
      msg="SUCCESSFUL: No updates required by Terraform."
      echo; echo "${msg}"
      ;;
    1)
      msg="FATAL: Error in the Terraform plan. Cannot continue."
      echo; echo -e "${RED}${msg}${NC}"
      exit 3
      ;;
    2)
      terraform_run
      ;;
    *)
      echo " invalid return code."
      ;;
  esac
}

user_validation(){

  if [[ "${#TICKET_ID}" != "4" || ${TICKET_ID} =~ [^[:digit:]] ]]; then
    #statements
    echo "WARNING : Invalid Ticket ID : ${TICKET_ID}, Please check and Try Again"
  else

    if [[ "${SECURITY_CHECK}" == "${TF_PASS}" ]]; then
      echo "Hi ${CREATOR}, You are Authorized user"
      echo "This job executed by ${CREATOR}"

      terraform_execute

    else
      echo "Sorry !! You are not Authorized to execute this job. Contact to Jenkins Admin"
    fi
  fi
}


if [[ "${TF_MODE}" == "destroy" && "${SECURITY_CHECK}" == "${TF_PASS}" ]]; then
  echo "ENVIRONMENT is Destroying..."
   terraform_execute
 elif [[ "${TF_MODE}" != "destroy" ]]; then
   user_validation
else
  echo "Incorrect SECURITY CHECK Value."

fi

if [[  "${TF_MODE}" == "apply" ]]; then
  export PUBLIC_IP=$($TERRAFORM output -state="${STATE_FILE}" PUBLIC_IPS)
  echo "Public IP ${PUBLIC_IPS}"
fi
