#!/bin/bash

# Get list ids without header, default and given by command line
# param: $1 the manila list command
# param: $2 the list of ids to be ignored
# param: $3 the all flag
get_ids () {
	LIST_COMMAND="$1"
	IGNORE_IDS="!/YES/ && // "
	for ID in $(echo $2 | sed "s/,/ /g" ); do
		IGNORE_IDS="$IGNORE_IDS && !/$ID/"
	done
	IGNORE_IDS="$IGNORE_IDS {print \$2}"


	echo "$(manila $LIST_COMMAND $3 --columns id,is_default | tail -n +4 | head -n -1 | awk "$IGNORE_IDS")"
}

# Delete the given ids
# param: $1 the manila delete command
# param: $2 list of string ids
delete_ids () {
	DELETE_COMMAND="$1"
	shift
	local arr=("$@")
	for ID in "${arr[@]}"; do
		echo -n "-> Deleting the $ID... "
		manila $DELETE_COMMAND $ID
		if [ "$?" = "0" ]; then
			echo "It has been deleted!"
		fi
	done
}

# Delete the given ids
# param: $1 the manila delete command
# param: $2 list of string ids
delete_force_ids () {
	DELETE_COMMAND="$1"
	shift
	local arr=("$@")
	for ID in "${arr[@]}"; do
		echo -n "-> Deleting the $ID... "
		manila $DELETE_COMMAND --force $ID
		if [ "$?" = "0" ]; then
			echo "It has been deleted!"
		fi
	done
}

# Delete share-types
# param: $1 skiped ids
delete_types () {
	echo -e "\n----- Deleting the share-types -----"

	COMMAND="type-list"
	ALL_FLAG="--all"
	SKIP_IDS="$1,"
	IDS=$(get_ids $COMMAND $SKIP_IDS $ALL_FLAG)
	if [ -z "$IDS" ]; then
		echo "Nothing to be deleted!"
		return
	fi

	COMMAND="type-delete"
	delete_ids $COMMAND $IDS
}


# Delete share-networks
# param: $1 skiped ids
delete_networks () {
	echo -e "\n----- Deleting the share-networks -----"

	COMMAND="share-network-list"
	ALL_FLAG="--all"
	SKIP_IDS="$1,"
	IDS=$(get_ids $COMMAND $SKIP_IDS $ALL_FLAG)
	if [ -z "$IDS" ]; then
		echo "Nothing to be deleted!"
		return
	fi

	COMMAND="share-network-delete"
	delete_ids $COMMAND $IDS
}

# Delete share-servers
# param: $1 skiped ids
delete_servers () {
	echo -e "\n----- Deleting the share-servers -----"

	COMMAND="share-server-list"
	SKIP_IDS="$1,"
	IDS=$(get_ids $COMMAND $SKIP_IDS)
	if [ -z "$IDS" ]; then
		echo "Nothing to be deleted!"
		return
	fi

	COMMAND="share-server-delete"
	delete_ids $COMMAND $IDS
}

# Delete shares
# param: $1 skiped ids
delete_shares () {
	echo -e "\n----- Deleting the shares -----"

	COMMAND="list"
	ALL_FLAG="--all"
	SKIP_IDS="$1,"
	IDS=$(get_ids $COMMAND $SKIP_IDS $ALL_FLAG)
	if [ -z "$IDS" ]; then
		echo "Nothing to be deleted!"
		return
	fi

	COMMAND="force-delete"
	delete_ids $COMMAND $IDS
}

# Delete snapshots
# param: $1 skiped ids
delete_snapshots () {
	echo -e "\n----- Deleting the snapshots -----"

	COMMAND="snapshot-list"
	ALL_FLAG="--all"
	SKIP_IDS="$1,"
	IDS=$(get_ids $COMMAND $SKIP_IDS $ALL_FLAG)
	if [ -z "$IDS" ]; then
		echo "Nothing to be deleted!"
		return
	fi

	COMMAND="snapshot-force-delete"
	delete_ids $COMMAND $IDS
}

# Delete share-groups
# param: $1 skiped ids
delete_groups () {
	echo -e "\n----- Deleting the share-groups -----"

	COMMAND="share-group-list"
	ALL_FLAG="--all"
	SKIP_IDS="$1,"
	IDS=$(get_ids $COMMAND $SKIP_IDS $ALL_FLAG)
	if [ -z "$IDS" ]; then
		echo "Nothing to be deleted!"
		return
	fi

	COMMAND="share-group-delete"
	delete_force_ids $COMMAND $IDS
}

# Delete share-group-snapshots
# param: $1 skiped ids
delete_group_snapshots () {
	echo -e "\n----- Deleting the share-group-snapshots -----"

	COMMAND="share-group-snapshot-list"
	ALL_FLAG="--all"
	SKIP_IDS="$1,"
	IDS=$(get_ids $COMMAND $SKIP_IDS $ALL_FLAG)
	if [ -z "$IDS" ]; then
		echo "Nothing to be deleted!"
		return
	fi

	COMMAND="share-group-snapshot-delete"
	delete_force_ids $COMMAND $IDS
}

# Delete share-group-types
# param: $1 skiped ids
delete_group_types () {
	echo -e "\n----- Deleting the share-group-types -----"

	COMMAND="share-group-type-list"
	ALL_FLAG="--all"
	SKIP_IDS="$1,"
	IDS=$(get_ids $COMMAND $SKIP_IDS $ALL_FLAG)
	if [ -z "$IDS" ]; then
		echo "Nothing to be deleted!"
		return
	fi

	COMMAND="share-group-type-delete"
	delete_ids $COMMAND $IDS
}

# Delete security-services
# param: $1 skiped ids
delete_security_services () {
	echo -e "\n----- Deleting the security-services -----"

	COMMAND="security-service-list"
	ALL_FLAG="--all"
	SKIP_IDS="$1,"
	IDS=$(get_ids $COMMAND $SKIP_IDS $ALL_FLAG)
	if [ -z "$IDS" ]; then
		echo "Nothing to be deleted!"
		return
	fi

	COMMAND="security-service-delete"
	delete_ids $COMMAND $IDS
}

delete_replicas () {
	# TODO: delete share replicas (should put all in inactive state)
	echo -e "\n----- Deleting the share-replicas -----"
	echo "Skipped, it should be deleted manually!"
}

##### Main ####

# The order for removing must follow:
#   0. Replicas
#   1. Snapshots (share/share-group)
#   2. Shares
#   3. Groups
#   4. Group-types
#   3. Servers
#   4. Networks
#   5. Security services
#   6. Types

delete_replicas $1
delete_snapshots $1
delete_group_snapshots $1
delete_shares $1
delete_groups $1
delete_group_types $1
delete_servers $1
delete_networks $1
delete_security_services $1
delete_types $1
