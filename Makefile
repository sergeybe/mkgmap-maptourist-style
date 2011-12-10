

STYLE?=		config

INPUT?=		input/RU-KEM.osm.pbf

MKGMAP?=	java -Xmx1072m -jar bin/mkgmap.jar
SPLITTER?=	java -Xmx1072m -jar bin/splitter.jar
OSMOSIS?=	bin/osmosis

all: splitpbf convert

splitpbf:
	${SPLITTER} \
		--overlap=20000 \
		--max-nodes=1000000 \
		--no-trim \
		--output=pbf \
		--output-dir=splitted \
		${INPUT} > splitted/splitLocal_log

convert:
	${MKGMAP} \
		--output-dir=output \
		--description="OSM MapTourist" \
		--family-name="OSM MapTourist `date "+%Y-%m-%d"`" \
		--series-name="OSM MapTourist `date "+%Y-%m-%d"`" \
		--overview-mapname="OSM_MapTourist" \
		--area-name="OSM `date "+%Y-%m-%d"`" \
		--family-id=480 \
		--keep-going \
		--read-config=optionsfile.args \
		--style-file=${STYLE} \
		--style=${STYLE} \
		--gmapsupp \
		-c splitted/template.args ${STYLE}/M00001e0.TYP

mkgbnd2:
	${OSMOSIS}  --read-pbf file=${INPUT} outPipe.0=1 \
	--tee 2 inPipe.0=1 outPipe.0=2 outPipe.1=3 \
	--buffer inPipe.0=3 outPipe.0=4 \
	--buffer inPipe.0=2 outPipe.0=5 \
	--tag-filter accept-relations boundary=administrative,postal_code inPipe.0=4 outPipe.0=6 \
	--used-way inPipe.0=6 outPipe.0=7 \
	--tag-filter reject-relations inPipe.0=5 outPipe.0=8 \
	--tag-filter accept-ways boundary=administrative,postal_code inPipe.0=8 outPipe.0=9 \
	--used-node inPipe.0=9 outPipe.0=10 \
	--used-node inPipe.0=7 outPipe.0=11 \
	--merge inPipe.0=10 inPipe.1=11 outPipe.0=12 \
	--write-pbf file=boundary/local-boundaries.osm.pbf omitmetadata=true compress=deflate inPipe.0=12 

	${MKGMAP} \
	--createboundsfile=boundary/local-boundaries.osm.pbf \
	--bounds=./boundary/local/