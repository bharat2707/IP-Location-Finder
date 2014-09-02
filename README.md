IP-Location-Finder
==================

Enter IP address and see what it does. In order to use the script follow the instructions provided below and also explanation to few main functions used is provided
Description:
#If you are entering only one argument it should be IP address or File containing only Ip address seperated by new line.You can enter 3 arguments to get the range of details for particular section of ip address in the file.For example if you need 10-20 ip address details then you have to enter IP address file in said format followed by 10 20..It will fetch details of related to IP address present from line 10 to 20.
#Modules to be installed : Mechanize,LWP::ConnCache
#Function Explantion : -> error_exit: Prints PAGE error if it is an error from the code and exits the script. Prints SITE error if it is fault from the site 
#                         and exits from the script. Prints HTTP error and exits the script if HTTP error occurs at site. Prints USERACT when action from the users
#                         side is required.
#                      -> debug_print : Prints the message required for debugging while running the script.If you do not want debug messages just set $k_debug flag
#                         to zero.
#                      -> get_response_content :Checks if the content received is proper and dumpes the outfile in html format. 
#                      -> do_mech_post : It is used to post form along with it is parameters. Hidden parameters are handled here itself.
##This will give you state, region, country and ip address if you input ip address or file containing ip_address and also you can specify the range present in your file
