#!/bin/zsh

mkdir -p compiled images

# ############ Convert friendly and compile to openfst ############
for i in friendly/*.txt; do
	echo "Converting friendly: $i"
   python compact2fst.py  $i  > sources/$(basename $i ".formatoAmigo.txt").txt
done


# ############ convert words to openfst ############
for w in tests/*.str; do
	echo "Converting words: $w"
	./word2fst.py `cat $w` > tests/$(basename $w ".str").txt
done


# ############ Compile source transducers ############
for i in sources/*.txt tests/*.txt; do
	echo "Compiling: $i"
    fstcompile --isymbols=syms.txt --osymbols=syms.txt $i | fstarcsort > compiled/$(basename $i ".txt").fst
done

# ############ CORE OF THE PROJECT  ############
echo "Creating MetaphoneLN"
fstcompose compiled/step1.fst compiled/step2.fst > compiled/m12.fst
fstcompose compiled/m12.fst compiled/step3.fst > compiled/m13.fst
fstcompose compiled/m13.fst compiled/step4.fst > compiled/m14.fst
fstcompose compiled/m14.fst compiled/step5.fst > compiled/m15.fst
fstcompose compiled/m15.fst compiled/step6.fst > compiled/m16.fst
fstcompose compiled/m16.fst compiled/step7.fst > compiled/m17.fst
fstcompose compiled/m17.fst compiled/step8.fst > compiled/m18.fst


fstcompose compiled/m18.fst compiled/step9.fst > compiled/metaphoneLN.fst



echo "Inverting MetaphoneLN"
fstinvert compiled/metaphoneLN.fst > compiled/invertMetaphoneLN.fst


############ generate PDFs  ############
## A PDF from the steps, metaphoneLN or invertMethaponeLN is
## unnecessary big and cannot be visualized correctly
# rm compiled/m[0-9]*.fst
# rm compiled/invertMetaphoneLN.fst
# rm compiled/metaphoneLN.fst
# echo "Starting to generate PDFs"
# for i in compiled/*.fst; do
# 	echo "Creating image: images/$(basename $i '.fst').pdf"
#   fstdraw --portrait --isymbols=syms.txt --osymbols=syms.txt $i | dot -Tpdf > images/$(basename $i '.fst').pdf
# done



# ############ tests  ############

echo "\nTesting Step 1 with (ERRORS → ERORS), (ACCORDING → ACCORDING) & (RUSSIAN → RUSIAN)"
for w in compiled/t1-*.fst; do
    fstcompose $w compiled/step1.fst | fstshortestpath | fstproject --project_type=output |
    fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt
    echo "\n"
done

echo "\nTesting Step 2 with (KNEE → NEE), (GNOME → NOME), (WRAPPERS → RAPPERS), (BREADCRUMB → BREADCRUM)"
for w in compiled/t2-*.fst; do
    fstcompose $w compiled/step2.fst | fstshortestpath | fstproject --project_type=output |
    fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt
    echo "\n"
done

echo "\nTesting Step 3 with:
        \n SCHOOL → SKHOOL, ACHIEVER → AXHIEVER, PRONUNCIATION → PRONUNXIATION,
        \n	VICIOUS → VISIOUS, ABSENCE → ABSENSE, CYBERNETICIAN → SYBERNETIXIAN,
        \n	CULTURE → KULTURE"
for w in compiled/t3-*.fst; do
    fstcompose $w compiled/step3.fst | fstshortestpath | fstproject --project_type=output |
    fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt
    echo "\n"
done

echo "\nTesting Step 4 with
        \n PLEDGES → PLEJGES, FUDGY → FUJGY, BUDGIES → BUJGIES,
	    \n ABDUCED → ABTUCET, AID → AIT, DUAL → TUAL"
for w in compiled/t4-*.fst; do
    fstcompose $w compiled/step4.fst | fstshortestpath | fstproject --project_type=output |
    fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt
    echo "\n"
done

echo "\nTesting Step 5 with
        \n FIGHT → FIHT, FOREIGN → FOREIN, SIGNED → SINED"
for w in compiled/t5-*.fst; do
    fstcompose $w compiled/step5.fst | fstshortestpath | fstproject --project_type=output |
    fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt
    echo "\n"
done

echo "\nTesting Step 6 with
        \n FIHT → FIT, MAHARAJAH → MAHARAJA
        \n LUCK → LUK, PHOTO → FOTO, QUITE → KUITE,
        \n SHOULD → XHOULD, COMISIONER → COMIXIONER, RUSIA → RUXIA"
for w in compiled/t6-*.fst; do
    fstcompose $w compiled/step6.fst | fstshortestpath | fstproject --project_type=output |
    fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt
    echo "\n"
done

echo "\nTesting Step 7 with
        \n SUBSTANTIAL → SUBSTANXIAL, CALCULATION → CALCULAXION,
        \n THE → 0E, MATCH → MACH, HAVE → HAFE, WHAT → WAT"
for w in compiled/t7-*.fst; do
    fstcompose $w compiled/step7.fst | fstshortestpath | fstproject --project_type=output |
    fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt
    echo "\n"
done

echo "\nTesting Step 8 with
        \n XENON → SENON, SEX → SEKS, LAWN → LAN, BY → B,
        \n KEYBOARD → KEBOARD, SIZE → SISE"
for w in compiled/t8-*.fst; do
    fstcompose $w compiled/step8.fst | fstshortestpath | fstproject --project_type=output |
    fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt
    echo "\n"
done

echo "\nTesting Step X with
        \n USE → US, KEBOARD → KBRD, AERIAL → ARL"
for w in compiled/t9-*.fst; do
    fstcompose $w compiled/stepX.fst | fstshortestpath | fstproject --project_type=output |
    fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt
    echo "\n"
done

echo "Testing our Names"
for w in compiled/t-*-std-in.fst; do
    fstcompose $w compiled/metaphoneLN.fst | fstshortestpath | fstproject --project_type=output |
    fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt
    echo "\n"
done

echo "Inverting our Phonetic Names"
for w in compiled/t-*-std1-in.fst; do
    fstcompose $w compiled/invertMetaphoneLN.fst | fstshortestpath | fstproject --project_type=output |
    fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./syms.txt
    echo "\n"
done