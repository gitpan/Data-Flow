# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN {print "1..7\n";}
END {print "not ok 1\n" unless $loaded;}
use Data::Flow;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

$recipe = {
	   path1 => { default => './MANI'},
	   obj => { class_filter => ['new', 'A']},
	   text => { prerequisites => ['contents1'] ,
		     output => sub { shift->{contents1} } },
	   text2 => { prerequisites => ['contents2'] ,
		      output => sub { shift->{contents2} } },
	   text3 => { prerequisites => ['contents3'] ,
		      output => sub { shift->{contents3} } },
	   contents1 => { filter => [ sub { shift }, 'contents' ] },
	   contents2 => { class_filter => [ 'x', 'A', 'contents1' ] },
	   contents3 => { method_filter => [ 'x', 'obj', 'contents1' ] },
	   contents => { prerequisites => ['path1', 'path2'] ,
			 process => sub {
			   my $data = shift; 
			   $data->{ shift() } = 
			     `cat $data->{path1}$data->{path2}`;
			 },
		       },
	  };

#$data = {};

my $request = new Data::Flow $recipe;
tie %request, Data::Flow, $recipe;

#request($recipe, $data, 'text');

$request->set('path2', 'FEST');

print $request->get('text') eq `cat MANIFEST` 
  ? "ok 2\n" : "not ok 2\n";
print $request->get('text2') eq  $request->get('text') 
  ? "ok 3\n" : "not ok 3\n";
print $request->get('text3') eq  $request->get('text') 
  ? "ok 4\n" : "not ok 4\n";

$request{path2} = 'FEST';

print $request{text} eq `cat MANIFEST` 
  ? "ok 5\n" : "not ok 5\n";
print $request->get('text2') eq  $request{text2} 
  ? "ok 6\n" : "not ok 6\n";
print $request->get('text3') eq  $request{text3} 
  ? "ok 7\n" : "not ok 7\n";

package A;
sub x {shift; shift}
sub new {bless []}
