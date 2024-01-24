class Difmap < Formula
  desc "Caltech VLBI software package for interferometric imaging"
  homepage "https://sites.astro.caltech.edu/~tjp/citvlb/index.html"
  url "ftp://ftp.astro.caltech.edu/pub/difmap/difmap2.5p.tar.gz"
  version "2.5p"
  sha256 "458fdc0f85eb03974b264061c0f171ad15e46d6f5d4fc45268f42950cbb3d8ea"

  depends_on "gcc"
  depends_on "libx11"
  depends_on "pgplot"

  fails_with :clang do
    cause "Miscompilation resulting in segfault on queries"
  end

  patch :p0 do
    url "https://raw.githubusercontent.com/kazuakiyama/hb-difmap-patches/1a9d6fa75a6b27c87a10ac4f59abbf644349da8e/patch_difmap2.5p_configure.diff"
    sha256 "1e906d857a06cce0a8066a489f032edafd5af34e1877b809688efe501d007482"
  end

  def install
    ENV.fortran
    ENV.deparallelize
    ENV.append "CCOMPL", :gcc

    pgplotlib = "-L#{HOMEBREW_PREFIX}/lib -lpgplot -lX11 -lpng"

    inreplace "configure" do |s|
      s.change_make_var! "HELPDIR", prefix
      s.change_make_var! "PGPLOT_LIB", pgplotlib
    end

    if (system 'sw_vers -productVersion').to_f >= 13.0
      inreplace "configure", "(cd libtecla_src; ./configure --without-man-pages)", "(cd libtecla_src ./configure --without-man-pages CFLAGS=-mmacosx-version-min=12.4.0)"
    end

    system "./configure", "intel-osx-gcc"
    system "./makeall"

    prefix.install Dir["help/*.hlp"]
    bin.install ["difmap"]
  end

  def caveats
    <<~EOF
      Don't forget to add paths for PGPLOT before using DIFMAP.
      For instance, you can add the following lines to your ~/.bash_profile or ~/.zshrc file
      (and remember to source the file to update your current session):
      PGPLOT_DIR=`brew --prefix pgplot`/share
      if [ -e $PGPLOT_DIR ]; then
        export PGPLOT_DIR=$PGPLOT_DIR
        export PGPLOT_DEV=/xwin       # This is up to your preference. /xserve might be your choise.
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PGPLOT_DIR
      fi
    EOF
  end

  test do
    system "false"
  end
end
