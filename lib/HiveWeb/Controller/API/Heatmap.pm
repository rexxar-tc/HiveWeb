package HiveWeb::Controller::API::Heatmap;
use Moose;
use namespace::autoclean;

use Math::Round;

BEGIN { extends 'Catalyst::Controller' }

sub log10 :Private
	{
	my $n = shift;

	return log($n);
	}

sub index :Path :Args(0)
	{
	my ($self, $c) = @_;

	$c->detach('accesses');
	}

sub accesses :Local :Args(0)
	{
	my ($self, $c)   = @_;
	my $out          = $c->stash()->{out};
	my $in           = $c->stash()->{in};
	$out->{response} = \0;

	my $dow   = [];
	my $max   = 0;
	my $scale = sub { return shift; };
	my $item  = $in->{item} // 'main_door';
	my $i     = $c->model('DB::Item')->find({ name => $item });

	if (!$i)
		{
		$out->{response} = 'Invalid item name.';
		return;
		}

	my $search =
		{
		granted => 't',
		item_id => $i->item_id(),
		};

	$scale = \&log10
		if (lc($in->{scale}) eq 'log');

	my $heatmap = $c->model('DB::AccessLog')->heatmap()->search($search);
	if (exists($in->{range}))
		{
		my $range = lc($in->{range});
		if ($range eq 'year')
			{
			$search->{access_time} = { '>=' => \"now() - interval '1 year'" };
			}
		elsif ($range eq 'half_year')
			{
			$search->{access_time} = { '>=' => \"now() - interval '6 months'" };
			}
		elsif ($range eq 'quarter')
			{
			$search->{access_time} = { '>=' => \"now() - interval '3 months'" };
			}
		elsif ($range eq 'month')
			{
			$search->{access_time} = { '>=' => \"now() - interval '1 month'" };
			}
		elsif ($range ne 'all')
			{
			$out->{response} = 'Invalid range specified.';
			return;
			}
		}

	for (my $i = 0; $i < 7; $i++)
		{
		my $qhour = [];
		for (my $j = 0; $j < (24 * 4); $j++)
			{
			push(@$qhour, 0);
			}
		push(@$dow, $qhour);
		}

	while (my $entry = $heatmap->next())
		{
		my $column = $entry->get_column('hour') * 4 + $entry->get_column('qhour');
		my $value  = $entry->get_column('count');
		$max = $value
			if ($max < $value);
		$dow->[$entry->get_column('dow')]->[$column] = $value;
		}

	$max = $scale->($max);

	for (my $i = 0; $i < 7; $i++)
		{
		for (my $j = 0; $j < (24 * 4); $j++)
			{
			my $v = int($dow->[$i]->[$j]);
			if ($v)
				{
				$v = ($scale->($v) * 100) / $max;
				$dow->[$i]->[$j] = round($v);
				}
			}
		}

	$out->{accesses} = $dow;
	$out->{response} = \1;
	}

__PACKAGE__->meta->make_immutable;

1;
