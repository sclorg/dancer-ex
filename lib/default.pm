package default;
use Dancer2 ':syntax';
use Template;
use DBI;
use DBD::mysql;

set template => 'template_toolkit';
set layout => undef;
set views => File::Spec->rel2abs('./views');

sub get_connection{
  my $service_name=uc $ENV{'DATABASE_SERVICE_NAME'};
  my $db_host=$ENV{"${service_name}_SERVICE_HOST"};
  my $db_port=$ENV{"${service_name}_SERVICE_PORT"};
  my $dbh=DBI->connect("DBI:mysql:database=$ENV{'MYSQL_DATABASE'};host=$db_host;port=$db_port",$ENV{'MYSQL_USER'},$ENV{'MYSQL_PASSWORD'}) or return 0;
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

true;
