class Difmap < Formula
  desc "Caltech VLBI software package for interferometric imaging"
  homepage "https://sites.astro.caltech.edu/~tjp/citvlb/index.html"
  url "ftp://ftp.astro.caltech.edu/pub/difmap/difmap2.5q.tar.gz"
  version "2.5q"
  sha256 "18f61641a56d41624e603bf64794c9f1b072eea320a0c1e0a22ac0ca4d3cef95"
  revision 2

  depends_on "gawk"
  depends_on "gcc"
  depends_on "libx11"
  depends_on "pgplot"

  fails_with :clang do
    cause "Miscompilation resulting in segfault on queries"
  end

  patch :p0 do
    url "https://raw.githubusercontent.com/kazuakiyama/hb-difmap-patches/2496fc72884034f1daacf3959f8e73dc51c23a62/patch_difmap2.5q_configure.diff"
    sha256 "49f48f93c2bdf294c7daa20448e3dd8914d67903847df74699f0ceafa23750d5"
  end

  def install
    ENV.fortran
    ENV.deparallelize
    ENV.append "CCOMPL", :gcc
    
    pgplotlib = "-L#{HOMEBREW_PREFIX}/lib -lpgplot -lX11 -lpng"
    ENV.append "PGPLOT_LIB", pgplotlib

    inreplace "configure" do |s|
      s.change_make_var! "HELPDIR", prefix
      s.change_make_var! "PGPLOT_LIB", pgplotlib
    end

    if MacOS.version >= :ventura
      inreplace "configure", "(cd libtecla_src; ./configure --without-man-pages)", "(cd libtecla_src ./configure --without-man-pages CFLAGS=-mmacosx-version-min=12.4.0)"
    end

    on_intel do
      #system "./configure", "intel-osx-gcc"
      system "./configure", "intel-osx-gcc", "CCOMPL=#{:gcc}", "PGPLOT_LIB=#{pgplot}", "HELPDIR=#{prefix}"
    end

    on_arm do
      system "./configure", "arm-osx-gcc"
    end

    system "./makeall"

    prefix.install Dir["help/*.hlp"]
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
    system "false"
  end
end
