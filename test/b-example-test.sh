#!/usr/bin/env bash
# file: b-example-test.sh
#### $$VERSION$$ v0.72-1-g67c47ac

# include common functions and definitions
# shellcheck source=test/ALL-tests.inc.sh
source "./ALL-tests.inc.sh"

if [ -f "${TESTDIR}/bashbot.sh" ]; then
	echo "${SUCCESS} bashbot.sh exist!"
	exit 0
else
	echo "${NOSUCCESS} ${TESTDIR}/bashbot.sh missing!"
	exit 1
fi

