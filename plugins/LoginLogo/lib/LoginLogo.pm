package LoginLogo;

use strict;
use warnings;
use base 'MT::Plugin';
use utf8;
use MT::Image;
use File::Path 'make_path';

sub cb_init {
    my $p = shift;
    return bless $p, 'LoginLogo';
}

sub save_config {
    my $plugin = shift;
    my ( $param, $scope ) = @_;

    my $app                   = MT->instance;
    my $mt_static_images_path = MT->config->StaticFilePath . '/images/login_logo';

    my $q = $app->{query};

    # ファイルアップロードフィールドからファイルハンドルを取得
    my $fh = $q->upload('loginlogo');

    if ($fh) {
        my ( $width, $height, $type ) = MT::Image->get_image_info( Fh => $fh );
        my %allowed_types = (
            jpg  => 1,
            jpeg => 1,
            png  => 1,
            gif  => 1,
        );

        unless ( $allowed_types{ lc($type) } ) {

            # 許可されていないファイルタイプの場合、エラーを返す
            return $plugin->error(
                "アップロードされたファイルは許可されている画像ファイル形式（jpg, jpeg, png, gif）ではありません。");
        }
    }
    else {
        return;
    }

    # アップロードされたファイルの拡張子を取得
    my ($ext) = $fh =~ /(\.[^.]+)$/;

    # 安全なファイル名を生成
    my $safe_filename = "logo_" . time() . $ext;
    my $upload_path   = File::Spec->catfile( $mt_static_images_path, $safe_filename );

    # ファイルを保存先にコピー
    unless (-d $mt_static_images_path) {
    make_path($mt_static_images_path) or die "ディレクトリの作成に失敗しました: $!";
    }

    open my $out, '>', $upload_path or die "ファイルを開けません: $!";
    binmode $out;
    while ( my $bytesread = read $fh, my $buffer, 1024 ) {
        print $out $buffer;
    }
    close $out;

    $param->{loginlogo} = $safe_filename;    # 保存したファイルのパスを設定

    return $plugin->SUPER::save_config( $param, $scope );
}

1;
