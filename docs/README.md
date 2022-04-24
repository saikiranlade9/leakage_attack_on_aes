
Requirements to recreate the project: 
    1. Vivado Design Suite
    2. source files, testbench, tcl script as in the file structure.


You can go through the following steps to run the tcl script.

Step 1: Start Vivado Design Suite. You can see a tcl console on the left bottom of Vivado Design Suite.

Step 2: Move the course to bottom of the line (i.e to 'type a tcl command here').

Step 3: Switch to your folder location where you are having tcl script using pwd, cd commands.

Step 4: Once you changed your directory,Make sure that you are having tcl script in that location using 'dir' command.

Step 5: Run the script using the command source filename.tcl (In our case it is source ./create_project.tcl).

Step 6: Now you can see the Vivado design suite started to create design as per the TCL script demand.Wait for some minute to complete the procedure including setting up simulation.

Step 7: If all the steps so far went as planned, you will see simulation window. TCL console should show the output for 
    1. normal operations like encryption, decryption, hashing when trojan is not activated 
    2. 16 tests running encryption when trojan is activated
    3. leaked final round key
    4. expanded keys of previous round
    5. input secret key. 

