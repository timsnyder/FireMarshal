#!/bin/bash
# This workload changed a few options in the buildroot config, we verify that
# the changes took in this script.

echo "Starting Test"

#==============================================================================
# Password Test
# This modifies something simple (the password) but doesn't change which files
# are in the overlay.
#==============================================================================
echo "Checking if the password changed (changing something simple in buildroot config test)"

# This will print an error if testUser already exists but it doesn't break the
# test.
adduser -D testUser 2> /dev/null

su testUser -c "echo marshalTestPwd | su root -c true"
test_pass=$?

if [ $test_pass -eq 0 ]; then
    echo "PASS"
else
    echo "FAIL"
fi

#==============================================================================
# Vim Test
# The config also removed the vim package. Subtractive changes like this aren't
# handled well by buildroot so we have to be careful in marshal to ensure they
# actually show up (clean when needed).
#==============================================================================
echo "Checking if vim was removed (removing packages from buildroot config test)"

which vim
vim_detected=$?

if [ $vim_detected -eq 0 ]; then
    echo "FAIL"
else
    echo "PASS"
fi

#==============================================================================
# Depmod Test
# Depmod is enabled in a custom busybox config. This tests two features of
# environment variable handling:
#   -The path to the busybox config uses the marshal-provided MODIFYDISTRO_PATH
#   environment variable to find the workdir.
#   - The name of the busybox config file is passed explicitly through the
#   environment as MODIFYDISTRO_TEST_VAR.
#==============================================================================
echo "Checking if depmod showed up (environment variables test)"
depmod -n
test_pass=$?
if [ $test_pass -eq 0 ]; then
    echo "PASS"
else
    echo "FAIL"
fi

poweroff
