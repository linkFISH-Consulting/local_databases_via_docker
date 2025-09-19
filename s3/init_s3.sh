# needs to be run once, on the host

BUCKET_NAME="demo-bucket"
garage() {
    # shorthand to run garage commands inside the container
	docker exec -it lf_dev_s3 /garage "$@"
}

NODE_ID=$(garage node id -q | awk -F'@' 'NR==1{print $1}')
garage layout assign -z default -c 15G "$NODE_ID"
garage layout apply --version 1
garage bucket create "$BUCKET_NAME"
KEY_DETAILS=$(garage key create "$BUCKET_NAME" | awk '/==== ACCESS KEY INFORMATION ====/ {flag=1; next} /==== BUCKETS FOR THIS KEY ====/ {flag=0} flag')
garage bucket allow --read --write --owner "$BUCKET_NAME" --key "$BUCKET_NAME"

echo "Created bucket '$BUCKET_NAME' with access details:"
echo "$KEY_DETAILS"
