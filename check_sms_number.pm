package Koha::Plugin::check_sms_number::check_sms_number;

use Modern::Perl;

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

#basic functions

sub new {
    my ( $class, $args ) = @_;

    ## We need to add our metadata here so our base class can access it
    $args->{'metadata'} = $metadata;
    $args->{'metadata'}->{'class'} = $class;

    ## Here, we call the 'new' method for our base class
    ## This runs some additional magic and checking
    ## and returns our actual $self
    my $self = $class->SUPER::new($args);

    return $self;
}

sub configure {
    my ( $self, $args ) = @_;
    my $cgi = $self->{'cgi'};

	unless ($cgi->param('op') eq 'save'){

		my $template = $self->get_template({ file => 'configure.tt' });
		my $country = $self->retrieve_data('country');
		$template->param(
            country => $country,
        );
        $self->output_html( $template->output());
	}
    else {
		$self->store_data(
	    {
	        country => $cgi->param('country'),
	    }
	    );
	    $self->tool;
	 }

}


sub tool {
	my( $self, $args ) = @_;
	my $cgi = $self->{'cgi'};

	my @patrons = Koha::Patrons->search({});
	my $template = $self->get_template({ file => 'check_sms_number.tt'});
	my $extension = $cgi->param('extension');
	my $country = $self->retrieve_data('country');
	my $i = 0;

	if ( $cgi->param('op') eq 'search') {
		my $check = "check$country";
		my @patrons_with_smsnumbers;

		foreach my $patron (@patrons){
		my $number = $patron->smsalertnumber();

		if ($number) {
			unless (Koha::Plugin::check_sms_number::check_sms_number::fr::check($number, $extension)){
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

	if ($cgi->param('op') eq 'transformation'){

		$extension = $cgi->param('extension');
		my $transform = "transform$country";
		my @patrons_transformed ;
		my $min_one_check = 0;

		$i = 0;

		foreach my $patron (@patrons){

			my $number = $patron->smsalertnumber();
			my $id = $patron->id();

			if($cgi->param('transformed'.$id)){
				$min_one_check = 1;
				my $new_number = Koha::Plugin::check_sms_number::check_sms_number::fr::transform($number, $extension);
				push (@patrons_transformed,{'patron'=>$patron, 'number'=>$new_number });

				if ($patrons_transformed[$i]{'number'} == $number){
					$patrons_transformed[$i]{'number'} = "this number can't be transformed";
				}
			++$i;
			}
		}

		$template->param(
			min_one_check => $min_one_check,
			patron_tranformed => \@patrons_transformed,
			extension => $extension,
			transformation => 1,
		);
	}

	$template->param(
		country => $country,
		);

	$self->output_html( $template->output() );

}

sub install() {
    my ( $self, $args ) = @_;

    return 1;
}

sub uninstall() {
    my ( $self, $args ) = @_;
}

1;