use utf8;
package HiveWeb::Schema::Result::PurchaseSoda;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

__PACKAGE__->table('purchase_soda');

__PACKAGE__->add_columns(
	'purchase_id',
	{ data_type => 'uuid', is_foreign_key => 1, is_nullable => 0, size => 16 },
	'soda_id',
	{ data_type => 'uuid', is_foreign_key => 1, is_nullable => 0, size => 16 },
	'soda_quantity',
	{ data_type => 'integer', is_nullable => 0 },
);

__PACKAGE__->set_primary_key('purchase_id', 'soda_id');

__PACKAGE__->belongs_to(
	'purchase',
	'HiveWeb::Schema::Result::Purchase',
	{ purchase_id => 'purchase_id' },
	{ is_deferrable => 0, on_delete => 'RESTRICT', on_update => 'RESTRICT' },
);

__PACKAGE__->belongs_to(
	'soda',
	'HiveWeb::Schema::Result::SodaStatus',
	{ soda_id => 'soda_id' },
	{ is_deferrable => 0, on_delete => 'RESTRICT', on_update => 'RESTRICT' },
);

1;
