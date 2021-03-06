use utf8;
package HiveWeb::Schema::Result::DeviceItem;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components('InflateColumn::DateTime');

__PACKAGE__->table('device_item');

__PACKAGE__->add_columns(
  'device_id',
  { data_type => 'uuid', is_foreign_key => 1, is_nullable => 0, size => 16 },
  'item_id',
  { data_type => 'uuid', is_foreign_key => 1, is_nullable => 0, size => 16 },
);

__PACKAGE__->set_primary_key('device_id', 'item_id');

__PACKAGE__->belongs_to(
  'device',
  'HiveWeb::Schema::Result::Device',
  { device_id => 'device_id' },
  { is_deferrable => 0, on_delete => 'RESTRICT', on_update => 'RESTRICT' },
);

__PACKAGE__->belongs_to(
  'item',
  'HiveWeb::Schema::Result::Item',
  { item_id => 'item_id' },
  { is_deferrable => 0, on_delete => 'RESTRICT', on_update => 'RESTRICT' },
);

1;
