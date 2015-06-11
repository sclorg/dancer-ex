package default;
use Dancer2 ':syntax';
use Template;

set template => 'template_toolkit';
set layout => undef;
set views => File::Spec->rel2abs('./views');

get '/' => sub {

    template default => {};
};

true;
