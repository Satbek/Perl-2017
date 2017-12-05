#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";


# use this block if you don't need middleware, and only have a single target Dancer app to run here
use web_notes;

web_notes->to_app;

=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use web_notes;
use Plack::Builder;

builder {
    enable 'Deflater';
    web_notes->to_app;
}

=end comment

=cut

=begin comment
# use this block if you want to mount several applications on different path

use web_notes;
use web_notes_admin;

use Plack::Builder;

builder {
    mount '/'      => web_notes->to_app;
    mount '/admin'      => web_notes_admin->to_app;
}

=end comment

=cut

