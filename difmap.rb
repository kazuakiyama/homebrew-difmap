class Difmap < Formula
  desc "Caltech VLBI software package for interferometric imaging"
  homepage "https://sites.astro.caltech.edu/~tjp/citvlb/index.html"
  url "https://sites.astro.caltech.edu/~mcs/difmap/difmap2.5r.tar.gz"
  version "2.5r"
  sha256 "0152e145c9a52ae29aaaf2d51380fa0199d4b7a14c9cdf0b6c8fe9884fb4fe7b"

  depends_on "gawk"
  depends_on "gcc"
  depends_on "libx11"
  depends_on "pgplot"

  fails_with :clang do
    cause "Miscompilation resulting in segfault on queries"
  end

  # The configure script is unchanged between 2.5q and 2.5r.
  patch :p0 do
    url "https://raw.githubusercontent.com/kazuakiyama/hb-difmap-patches/8a4affbe67bb678e4b879f7fa90bb3d1df601c27/patch_difmap2.5q_configure.diff"
    sha256 "b448fc1dd1f30eb20b7c3bbd1790302bea3e7fdf9c85572d588aedef7e9e042c"
  end

  def install
    ENV.fortran
    ENV.deparallelize

    # C Compiler
    ENV.append "CC", "#{:gcc}"
    ENV.append "CCOMPL", "#{:gcc}"
    
    # Compiler settings for PGPLOT
    pgplotlib = "-L#{HOMEBREW_PREFIX}/lib -lpgplot -lX11 -lpng"
    ENV.append "PGPLOT_LIB", pgplotlib

    # Compiler settings for HELPDIR
    ENV.append "HELPDIR", "#{prefix}/help"
    
    # edit configure file
    inreplace "configure" do |s|
      s.change_make_var! "HELPDIR", "#{prefix}/help"
      s.change_make_var! "PGPLOT_LIB", pgplotlib
    end

    if MacOS.version >= :ventura
      inreplace "configure", "(cd libtecla_src; ./configure --without-man-pages)", "(cd libtecla_src; ./configure --without-man-pages CFLAGS='-mmacosx-version-min=12.4.0 -Wno-error=incompatible-pointer-types')"
    end

    on_intel do
      system "./configure", "intel-osx-gcc"
    end

    on_arm do
      system "./configure", "arm-osx-gcc"
    end

    system "./makeall"

    prefix.install Dir["help"]
    bin.install ["difmap"]
  end

  def caveats
    <<~EOF
      Don't forget to add paths for PGPLOT before using DIFMAP.
      For instance, you can add the following lines to your ~/.bash_profile or ~/.zshrc file
      (and remember to source the file to update your current session):
      PGPLOT_DIR=`brew --prefix pgplot`/lib
      if [ -e $PGPLOT_DIR ]; then
        export PGPLOT_DIR=$PGPLOT_DIR
        export PGPLOT_DEV=/xwin       # This is up to your preference. /xserve might be your choise.
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PGPLOT_DIR
      fi
    EOF
  end

  test do
    ENV["PGPLOT_DEV"] = "/null"
    output = pipe_output("#{bin}/difmap", "print 6*7\nquit\n", 0)
    assert_match "version #{version}", output
    assert_match(/\b42\b/, output)
    assert_predicate prefix/"help/difmap.hlp", :exist?
  end
end
