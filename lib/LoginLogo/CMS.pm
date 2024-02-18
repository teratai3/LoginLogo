package LoginLogo::CMS;
use strict;
use warnings;
use MT::Template::Context;

use HTML::TreeBuilder;
use MT::Log;
use utf8;
use MT::PluginData;
use HTML::Entities;

sub header {
    my ( $cb, $app, $tmpl, $tmpl_ref ) = @_;

    my $plugin = MT->component('LoginLogo');
    my $tree   = HTML::TreeBuilder->new;
    $tree->parse_content($tmpl);

    # id="brand"の要素を見つける
    my $brand_div = $tree->look_down( id => "brand" );
    if ($brand_div) {

        #  MT->log({
        #     message => $tmpl_ref,
        # });
        # id="brand"内のimgタグを見つける
        my $img  = $brand_div->look_down( _tag => 'img' );
        my $data = MT::PluginData->load( { plugin => 'LoginLogo' } );

        if ( $img && $data ) {
            my $big_data_structure = $data->data;
            if ( my $loginlogo_value = $big_data_structure->{loginlogo} ) {
                $loginlogo_value = encode_entities($loginlogo_value);
                my $old = '<mt:var name="static_uri">images/logo-fullname-color.svg';
                my $new = qq{<mt:var name="static_uri">images/login_logo/$loginlogo_value};
                $$tmpl =~ s!\Q$old\E!$new!;

                my $position = quotemeta(q{</head>});
                my $plugin_tmpl =
                  File::Spec->catdir( $plugin->path, 'tmpl', 'insert.tmpl' );
                my $insert =
                  qq{<mt:include name="$plugin_tmpl" component="sample">\n};
                $$tmpl =~ s/($position)/$insert$1/;
            }

            #  $img->attr(src => '/path/to/your/new/logo.png');
            # $$tmpl = $tree->as_HTML('<>&', "\t")
            # $tree->delete; # メモリの解放
        }
    }
}
1;
