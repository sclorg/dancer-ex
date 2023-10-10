package default;
use Dancer2 ':syntax';
use Template;
use DBI;
use DBD::MariaDB;

set template => 'template_toolkit';
set layout => undef;
set views => File::Spec->rel2abs('./views');

sub get_connection{
  my $service_name=uc $ENV{'DATABASE_SERVICE_NAME'};
  my $db_host=$ENV{"${service_name}_SERVICE_HOST"};
  my $db_port=$ENV{"${service_name}_SERVICE_PORT"};
  my $dbh=DBI->connect("DBI:MariaDB:database=$ENV{'MYSQL_DATABASE'};host=$db_host;port=$db_port",$ENV{'MYSQL_USER'},$ENV{'MYSQL_PASSWORD'}) or return 0;
  return $dbh;
}

sub init_db{

  my $dbh = $_[0];
  eval{ $dbh->do("DROP TABLE view_counter") };

  $dbh->do("CREATE TABLE view_counter (count INTEGER)");
  $dbh->do("INSERT INTO view_counter (count) VALUES (0)");
};

get '/' => sub {

    my $hasDB=1;
    my $dbh = get_connection() or $hasDB=0;
    my @data;
    $data[0]="No DB connection available";
    if ($hasDB==1) {
 		$dbh->prepare("SELECT * FROM view_counter")->execute() or init_db($dbh);

        my $sth = $dbh->prepare("UPDATE view_counter SET count = count + 1");
        $sth->execute();

        $sth = $dbh->prepare("SELECT * FROM view_counter");
        $sth->execute();
        @data = $sth->fetchrow_array();
        $sth->finish();
    }
    template default => {hasDB => $hasDB, data => $data[0]};
};

get '/health' => sub {
  my $dbh  = get_connection();
  my $ping = $dbh->ping();

  if ($ping and $ping == 0) {
    # This is the 'true but zero' case, meaning that ping() is not implemented for this DB type.
    # See: http://search.cpan.org/~timb/DBI-1.636/DBI.pm#ping
    return "WARNING: Database health uncertain; this database type does not support ping checks.";
  }
  elsif (not $ping) {
    status 'error';
    return "ERROR: Database did not respond to ping.";
  }
  return "SUCCESS: Database connection appears healthy.";
};

true;
