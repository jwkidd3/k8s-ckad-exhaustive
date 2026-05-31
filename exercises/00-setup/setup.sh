#!/usr/bin/env bash
# Expand the Cloud9 root EBS volume to 100 GB.
# Cloud-init will grow the partition and XFS filesystem on the next boot,
# so this script ends by asking you to reboot.

set -euo pipefail

TARGET_SIZE=100

echo "==> Fetching instance metadata (IMDSv2)..."
TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: ${TOKEN}" \
  http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s -H "X-aws-ec2-metadata-token: ${TOKEN}" \
  http://169.254.169.254/latest/meta-data/placement/region)

echo "    instance:  ${INSTANCE_ID}"
echo "    region:    ${REGION}"

echo "==> Locating root EBS volume..."
VOLUME_ID=$(aws ec2 describe-instances \
  --instance-ids "${INSTANCE_ID}" \
  --region "${REGION}" \
  --query "Reservations[0].Instances[0].BlockDeviceMappings[0].Ebs.VolumeId" \
  --output text)
CURRENT_SIZE=$(aws ec2 describe-volumes \
  --volume-ids "${VOLUME_ID}" \
  --region "${REGION}" \
  --query "Volumes[0].Size" \
  --output text)
echo "    volume:    ${VOLUME_ID} (currently ${CURRENT_SIZE} GB)"

if [[ "${CURRENT_SIZE}" -ge "${TARGET_SIZE}" ]]; then
  echo "Volume is already ${CURRENT_SIZE} GB (>= ${TARGET_SIZE} GB). Nothing to do."
  exit 0
fi

echo "==> Modifying volume to ${TARGET_SIZE} GB..."
aws ec2 modify-volume \
  --volume-id "${VOLUME_ID}" \
  --size "${TARGET_SIZE}" \
  --region "${REGION}" >/dev/null

echo "==> Waiting for volume modification to enter 'optimizing'..."
while true; do
  STATE=$(aws ec2 describe-volumes-modifications \
    --volume-ids "${VOLUME_ID}" \
    --region "${REGION}" \
    --query "VolumesModifications[0].ModificationState" \
    --output text)
  echo "    state: ${STATE}"
  if [[ "${STATE}" == "optimizing" || "${STATE}" == "completed" ]]; then
    break
  fi
  sleep 5
done

cat <<EOF

================================================================
Volume ${VOLUME_ID} is now ${TARGET_SIZE} GB at the EBS layer.

To pick up the new size at the OS layer, reboot the instance:

    sudo reboot

Cloud-init will grow the partition and XFS filesystem on boot.
After the instance comes back, reconnect to the Cloud9 IDE and
verify with:

    df -h /
================================================================
EOF
