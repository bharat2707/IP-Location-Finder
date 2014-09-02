###################################################################################################################################################################
#Modules to be installed : Mechanize,LWP::ConnCache
#Function Explantion : -> error_exit: Prints PAGE error if it is an error from the code and exits the script. Prints SITE error if it is fault from the site 
#                         and exits from the script. Prints HTTP error and exits the script if HTTP error occurs at site. Prints USERACT when action from the users
#                         side is required.
#                      -> debug_print : Prints the message required for debugging while running the script.If you do not want debug messages just set $k_debug flag
#                         to zero.
#                      -> get_response_content :Checks if the content received is proper and dumpes the outfile in html format. 
#                      -> do_mech_post : It is used to post form along with it is parameters. Hidden parameters are handled here itself.
##This will give u state, region, country and ip add if u input ip add or file containin ip_ad and also u can specify the range of ur file
###################################################################################################################################################################


use WWW::Mechanize;
use LWP::ConnCache;
use strict;

my $mech = WWW::Mechanize->new();
$mech->env_proxy();
$mech->conn_cache( LWP::ConnCache->new() );
$mech->add_header(
    'User-Agent'      => 'Mozilla/5.0 (compatible; MSIE 7.0; Windows NT 6.1; .NET CLR 1.1.4322; .NET CLR 2.0.50727)',
    'Accept'          => '*/*',
    'Accept-Language' => 'en-US',
);
my @p;
my ($c, $str, $i,$j, $z);
my $ip_addfile ; 
my ($response, $count, $k_debug) = ('',0,0);
my $ip_url = 'http://www.ipaddresslocation.org/ip-address-locator.php';
my $nip_url = 'http://www.topwebhosts.org/tools/ip-locator.php';

ip_loc();
exit(0);

sub ip_loc {
    readCmdlineArgs();
    
    $response = $mech->get($nip_url);
    get_response_content();

    if(scalar(@ARGV) == 3) {
        open( AS, '<', $ip_addfile ) || die("Terminating application - cannot open $ip_addfile"); 
        @p = <AS> ;
        for ($i = $j ; $i < $z ; $i++) {    
            my $formNumber = 3;
            my $form = $mech->form_number($formNumber);
            error_exit ("PAGE", "required form not found") if (! defined  $mech->form_number($formNumber) );
            my @input;
            $p[$i] =~ s/.*?(\d+\.\d+\.\d+\.\d+).*?/$1/;
            next if ($p[$i] !~ /\d+\.\d+\.\d+\.\d+/);
            push(@input , "query", $p[$i],"submit","Query");
            $response = do_mech_post($form ,\@input);
            get_response_content();
            get_demoinform();
        }
    }
    print_file($str, 'detail');
    close AS;
    exit if(scalar(@ARGV) == 3);
    #did this on purpose so that range block be different means inside file u can say from 10 to 20 then only the ip address b/w that range is taken n executed#

    
    if ($ip_addfile =~ /^\d+\.\d+\.\d+\.\d+$/ ) {
        my $formNumber = 3;
        my $form = $mech->form_number($formNumber);
        error_exit("PAGE","required form not found") if (! defined  $mech->form_number($formNumber) );
        my @input;
        push(@input , "query", $ip_addfile, "submit","Query" );
        $response = do_mech_post($form ,\@input);
        get_response_content();
        
        get_demoinform();

    } else {
        open( AS, '<', $ip_addfile ) || die("Terminating application - cannot open $ip_addfile"); 
        @p = <AS> ;
        for ($i = 0; $i < scalar(@p); $i++) {    
            my $formNumber = 3;
            my $form = $mech->form_number($formNumber);
            error_exit ("PAGE", "required form not found") if (! defined  $mech->form_number($formNumber) );
            my @input;
            $p[$i] =~ s/.*?(\d+\.\d+\.\d+\.\d+).*?/$1/;
            next if ($p[$i] !~ /\d+\.\d+\.\d+\.\d+/);
            push(@input , "query", $p[$i],"submit","Query");
            $response = do_mech_post($form ,\@input);
            get_response_content();
            get_demoinform();
        }
    }
    print_file($str, 'detail');
    close AS;
}

sub get_demoinform {
    my $match;
    $c =~ s/<!.*?-->//gs;
    if ($c =~ /Geolocation\s+data\s+from.*?<table.*?>(.*?)<\/table>.*?Geolocation\s+data\s+from/is) {
        $match = $1;
    } elsif ($c =~ /(\d+\.\d+\.\d+\.\d+)\s+is\s+not\s+a\s+valid\s+IP\s+address/is) {
        debug_print ("Invalid IP address " . $1 ."\n");
        return;
    } else {
        error_exit("PAGE","demographic info page not found");
    }
    my ($ipaddress, $city, $region, $country);
    my @rows = $match =~ /IP\s+Address.*?Region.*?ISP.*?<tr.*?>.*?<\/tr>.*?<tr.*?>(.*?)<\/tr/is;
    foreach my $row (@rows) {
        my @cols = $row =~ /<td.*?>(.*?)<\/td/sg;
        $ipaddress = $cols[0];
        $country = comma_space_free($cols[1]);
        $region = comma_space_free($cols[2]);
        $city = $cols[3];
    }
    print $ipaddress.",". $city.",".$region.",".$country. "\n";
    #$/ can be used instead of \n
    $str .= $ipaddress.",". $city.",".$region.",".$country."\n";
}

sub readCmdlineArgs {
    #If you are entering only one argument it should be IP address or File containing only Ip address seperated by new line.You can enter 3 arguments to get the range of details for particular section of ip address in the file.For example if you need 10-20 ip address details then you have to enter IP address file in said format followed by 10 20..It will fetch details of related to IP address present from line 10 to 20.      
    if (@ARGV eq 1){
       $ip_addfile = $ARGV[0];
    } elsif (scalar(@ARGV) == 3) {
        $ip_addfile = $ARGV[0];
        $j = $ARGV[1];
        $z = $ARGV[2];
    } else {
        print ("Enter the IP address or file name containing IP address");
        exit(1);
    }
}

sub print_file {
    my $str = shift;
    my $prefix   = shift;
    my $filename = $prefix. ".txt";
    open( OUTFILE, ">$filename" ) or error_exit( "IO", "Can't open $filename: $!" );
    open (OUTFILE, ">>$filename") if (-e $filename);
    binmode(OUTFILE);
    print OUTFILE $str;
    close OUTFILE;
}
        
sub get_response_content {
    $count += 1;
    $c = $response->decoded_content();
    $c = $response->content if(!$c);
    if ($k_debug) {
        my $ct            = $mech->ct;
        my $k_status_line = $response->status_line;
        my $k_url_base    = $response->base;
        my $k_cookies     = $mech->cookie_jar->as_string;
        debug_print("Status Line: $k_status_line");
        debug_print("Content Type: $ct");
        debug_print("Base: $k_url_base");
        $response->is_info ? debug_print("is_info: yes") : debug_print("is_info: no");
        $response->is_success ? debug_print("is_success: yes") : debug_print("is_success: no");
        $response->is_redirect ? debug_print("is_redirect: yes") : debug_print("is_redirect: no");
        $response->is_error ? debug_print("is_error: yes") : debug_print("is_error: no");
        debug_print($k_cookies);
        dump_file($c, "output");
    }
    if ( $count > 200 ) {
        error_exit( "PAGE", "Too many URL calls (may be looping). Goodbye!" );
    }
    if ( $response->is_error ) {
        error_exit( "HTTP", "Unable to fetch url#$count. Status: " . $response->status_line );
    }
}

sub debug_print {
    my $message = shift;
    print "Fetchdata: $message\n" if ($k_debug);
}

sub dump_file {
    my $local_c  = shift;
    my $prefix   = shift;
    my $filename = $prefix . $count . ".html";
    open( OUTFILE, ">$filename" ) or error_exit( "IO", "Can't open $filename: $!" );
    binmode(OUTFILE);
    print OUTFILE $local_c;
    close OUTFILE;
    debug_print("Response dumped in file $filename");
}

sub do_mech_post {
    my $form_object  = shift;    # HTML Form Object that Mech Object is pointing to
    my $input_fields = shift;    # Array Reference containing key-Value pairs non-hidden fields
    my $action      = shift;

    $action = $form_object->action if (!$action);
    my @html_input_objects = $mech->find_all_inputs();
    my $input_obj;
    my $ctr = 0;

    for (my $j = 0; $j < scalar(@html_input_objects); $j++) {
        $input_obj = $html_input_objects[$j];
        for (my $i = 0; $i < scalar(@$input_fields); $i++) {
            if ($input_obj->name eq @$input_fields[$i]) {
                $ctr = 0;
                last;
                $i++;
            } else {
                $ctr = 1;
            }
            $i++;
        }

        if ($input_obj->type eq "hidden" && $ctr) {
            push(@$input_fields, $input_obj->name, $input_obj->value);
        }
    }
    return $mech->post($action, $input_fields);    # $inputFields us array reference
}

sub comma_space_free {
    my $n = shift;
    $n =~ s/\,|\s+|\://gs;
    $n =~ s/<.*?>//sg;
    return $n;
}

sub error_exit {
    my $err_type = shift;
    my $message  = shift;
    if($c !~ /<\/body.*?>.*?<\/html.*?>/is && $c =~ /<html.*?>/is) {
        debug_print("Looks like incomplete page");
        $err_type = "SITE";
    }
    print "#ERROR $err_type $message\n";
    if($count >= 200) {
        sleep(2);
        exit(1);
    }
    sleep(2);
    exit(1);
}

