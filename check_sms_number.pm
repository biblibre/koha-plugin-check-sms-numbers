package Koha::Plugin::check_sms_number::check_sms_number;

use Modern::Perl;
no strict 'refs';
#required for all plugins
use base qw(Koha::Plugins::Base);

use Koha::Patrons;
use Koha::Plugin::check_sms_number::check_sms_number::fr;

#the table in the plugins list of koha
our $VERSION = "1.0";

our $metadata = {
    name            => 'Check sms number ',
    author          => 'Axel AMGHAR',
    description     => 'This plugin allow us to check phone numbers for all patrons',
    date_authored   => '2019-04-15',
    date_updated    => '2019-04-15',
    minimum_version => '1.0',
    maximum_version => undef,
    version         => $VERSION,
};

sub new {
    my ( $class, $args ) = @_;

    $args->{'metadata'} = $metadata;
    $args->{'metadata'}->{'class'} = $class;

    my $self = $class->SUPER::new($args);

    return $self;
}

sub configure {
    my ( $self, $args ) = @_;
    my $cgi = $self->{'cgi'};

    my $template = $self->get_template({ file => 'configure.tt' });
    my $country = $self->retrieve_data('country');
    my $op = $cgi->param('op');
    
    if ($op eq 'cancel_conf'){
    	$self->go_home();
    	exit;
    }
    
    if ($op eq 'save'){
	    
        $self->store_data({
            country => $cgi->param('country'),
        });
        $self->tool;
        exit;
	}

	$template->param(
        country => $country,
    );
    $self->output_html( $template->output());
}

sub tool {
    my( $self, $args ) = @_;
    my $cgi = $self->{'cgi'};

    my $template = $self->get_template({ file => 'check_sms_number.tt'});
    my $extension = $cgi->param('extension');
    my $country = $self->retrieve_data('country');
    my $string_check ;
    my $patrons_transformed ;
    my $i = 0;
    my $op = $cgi->param('op');
    
    #CANCEL
    if ($op eq 'cancel'){
        
        $op = 'search';       
    }

    #CONFIRM
    if ($op eq 'confirm'){
        
        my @ids = $cgi->multi_param('ids');
        my @new_numbers = $cgi->multi_param('new_numbers');
        $i = 0;
        
        foreach my $id (@ids){
            my $patron = Koha::Patrons->find($id);
            my $patron_id = $patron->id();
            
            unless ($new_numbers[$i] eq "This number can't be transformed"){
                $patron->set({ smsalertnumber => $new_numbers[$i]})->store;
           }
           ++$i;
        }
        
        $op = 'search';
    }
    
    #SEARCH    
    if ( $op eq 'search') {
        my @patrons = Koha::Patrons->search({});
        my @patrons_with_smsnumbers;
        $i = 0;
        
        foreach my $patron (@patrons){
            my $number = $patron->smsalertnumber();
            my $id = $patron->id();

            if ($number) {
                unless (eval 'Koha::Plugin::check_sms_number::check_sms_number::'.$country. '::check($number,$extension)'){
                    $patrons_with_smsnumbers[$i] = $patron;
                    ++$i;
                }
            }
        }

	    $template->param(
            extension => $extension,
            search => 1,
            patrons => \@patrons_with_smsnumbers,
        );
    }

    #TRANSFORMATION
    if ($op eq 'transformation'){

        my $min_one_check = 0;
        my @ids = $cgi->multi_param('transformed');
        $i = 0;
        my @new_numbers;
        
        foreach my $id (@ids){
            my $patron = Koha::Patrons->find($id);
            my $number = $patron->smsalertnumber();
            $min_one_check = 1;
            
            my $new_number = eval 'Koha::Plugin::check_sms_number::check_sms_number::'.$country.'::transform($number,$extension)';
              
            if ($new_number eq $number){
                $new_number = "This number can't be transformed";
            }
            $new_numbers[$i] = $new_number; 
            push @$patrons_transformed,{'patron'=>$patron, 'number'=>$new_number, 'old_number'=>$number , 'id'=>$id }; 
            ++$i;
        }
        
        foreach my $new_number (@new_numbers){
            unless ($new_number eq "This number can't be transformed"){
                $template->param(
                    ok => 1,
                );
        	}
        }
        
        $template->param(
            min_one_check => $min_one_check,
            patron_transformed => $patrons_transformed,
            ids => \@ids,
            new_numbers => \@new_numbers,
            transformation => 1,
        );
    }
        
    $template->param(
        country => $country,
        extension => $extension,
    );

    $self->output_html( $template->output() );
}

1;