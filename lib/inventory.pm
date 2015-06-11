package inventory;
use Dancer2 ':syntax';
use Dancer2 ':script';
use Template;
use DBI;
use DBD::mysql;

set template => 'template_toolkit';
set layout => undef;
set views => File::Spec->rel2abs('./views');

sub get_connection{
  my $dbh=DBI->connect("DBI:mysql:database=$ENV{'MYSQL_DATABASE'};host=$ENV{'DATABASE_SERVICE_HOST'};port=$ENV{'DATABASE_SERVICE_PORT'}",$ENV{'MYSQL_USER'},$ENV{'MYSQL_PASSWORD'}, { RaiseError => 1 } ) or die ("Couldn't connect to database: " . DBI->errstr );
  return $dbh;
}

sub init_db{

  my $dbh = $_[0];

  eval { $dbh->do("DROP TABLE foo") };

  $dbh->do("CREATE TABLE foo (id INTEGER not null auto_increment, name VARCHAR(20), email VARCHAR(30), PRIMARY KEY(id))");
  $dbh->do("INSERT INTO foo (name, email) VALUES (" . $dbh->quote("Eric") . ", " . $dbh->quote("eric\@example.com") . ")");
};

get '/user/:id' => sub {
    my $timestamp = localtime();
    my $dbh = get_connection();

    my $sth = $dbh->prepare("SELECT * FROM foo WHERE id=?") or die "Could not prepare statement: " . $dbh->errstr;
    $sth->execute(params->{id});

    my $data = $sth->fetchall_hashref('id');
    $sth->finish();

    template user => {timestamp => $timestamp, data => $data};
};

get '/' => sub {

    my $dbh = get_connection();

    eval { $dbh->prepare("SELECT * FROM foo")->execute() };
    init_db($dbh) if $@;

    my $sth = $dbh->prepare("SELECT * FROM foo");
    $sth->execute();

    my $data = $sth->fetchall_hashref('id');
    $sth->finish();

    my $timestamp = localtime();
    template index => {data => $data, timestamp => $timestamp};
};

post '/' => sub {

   my $name = params->{name};
   my $email = params->{email};

   my $dbh = get_connection();
   
   $dbh->do("INSERT INTO foo (name, email) VALUES (" . $dbh->quote($name) . ", " . $dbh->quote($email) . ") ");

   my $sth = $dbh->prepare("SELECT * FROM foo");
   $sth->execute();

   my $data = $sth->fetchall_hashref('id');
   $sth->finish();

   my $timestamp = localtime();
   template index => {data => $data, timestamp => $timestamp};
};

true;
