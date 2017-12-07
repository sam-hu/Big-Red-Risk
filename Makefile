test:
	ocamlbuild -use-ocamlfind state_test.byte && ./state_test.byte

play:
	ocamlbuild -use-ocamlfind -pkgs lymp -tag thread simple.native && ./simple.native

clean:
	ocamlbuild -clean
	rm -f checktypes.ml
	rm -f a2src.zip
