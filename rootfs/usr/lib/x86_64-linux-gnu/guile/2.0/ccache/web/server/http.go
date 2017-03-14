GOOF----LE-8-2.0�w      ]Z 4    h�C      ] g  guile�	 �	g  define-module*�	 �	 �	g  web�	g  server�	g  http�		 �	
g  filenameS�	f  web/server/http.scm�	g  importsS�	g  srfi�	g  srfi-1�	 �	g  selectS�	g  fold�	 �	 �	g  srfi-9�	 �	 �	g  rnrs�	g  bytevectors�	 �	 �	g  request�	 �	 �	g  response�	 �	  �	! �	"! �	#g  ice-9�	$g  poll�	%#$ �	&% �	' "& �	(g  set-current-module�	)( �	*( �	+g  socket�	,g  PF_INET�	-g  SOCK_STREAM�	.g  
setsockopt�	/g  
SOL_SOCKET�	0g  SO_REUSEADDR�	1g  bind�	2g  make-default-socket�	3g  <http-server>�	4g  %make-http-server-procedure�	5g  make-syntax-transformer�	65 �	75 �	8g  make-http-server�	9g  macro�	:g  $sc-dispatch�	;: �	<: �	=g  _�	>g  any�	?=>>> �	@g  syntax-object�	Ag  lambda�	Bg  m-AZNFNuzJHj3zfaL9NY031d-927�	Cg  top�	DBC �	Eg  ribcage�	Fg  t-924�	Gg  t-925�	Hg  t-926�	IFGH �	JDDD �	Kf  l-AZNFNuzJHj3zfaL9NY031d-932�	Lf  l-AZNFNuzJHj3zfaL9NY031d-933�	Mf  l-AZNFNuzJHj3zfaL9NY031d-934�	NKLM �	OEIJN �	PE �	Qg  x�	RQ �	SD �	Tf  l-AZNFNuzJHj3zfaL9NY031d-929�	UT �	VERSU �	Wg  shift�	Xg  	proc-name�	Yg  args�	ZXY �	[C �	\[[ �	]f  l-1H5JDRLBnbabw7jk2kqjyg-2767�	^f  l-1H5JDRLBnbabw7jk2kqjyg-2768�	_]^ �	`EZ\_ �	ag  key�	bg  value�	cg  name�	dg  formals�	eg  body�	fabcde �	g[[[[[ �	hf  l-1H5JDRLBnbabw7jk2kqjyg-2754�	if  l-1H5JDRLBnbabw7jk2kqjyg-2755�	jf  l-1H5JDRLBnbabw7jk2kqjyg-2756�	kf  l-1H5JDRLBnbabw7jk2kqjyg-2757�	lf  l-1H5JDRLBnbabw7jk2kqjyg-2758�	mhijkl �	nEfgm �	og  make-procedure-name�	po �	q[ �	rf  l-1H5JDRLBnbabw7jk2kqjyg-2738�	sr �	tEpqs �	u[ �	vf  l-1H5JDRLBnbabw7jk2kqjyg-2737�	wv �	xERuw �	yDOPVWPPPP`ntx �	zg  hygiene�	{z �	|@Ay{ �	}[OPV �	~z �	@+}~ � �g  poll-idx� �@�}~ � �g  poll-set� �@�}~ � ��� � �g  make-struct� �g  m-AZNFNuzJHj3zfaL9NY031d-922� ��C � �g  t-2978� �g  t-2977� �g  t-2976� ���� � �g  m-1H5JDRLBnbabw7jk2kqjyg-2979� ��C � ���� � �f  l-1H5JDRLBnbabw7jk2kqjyg-2983� �f  l-1H5JDRLBnbabw7jk2kqjyg-2984� �f  l-1H5JDRLBnbabw7jk2kqjyg-2985� ���� � �E��� � �g  	ctor-args� �� � �f  l-1H5JDRLBnbabw7jk2kqjyg-2959� �� � �E�u� � �g  ctor� �g  field� ��� � �f  l-1H5JDRLBnbabw7jk2kqjyg-2955� �f  l-1H5JDRLBnbabw7jk2kqjyg-2956� ��� � �E�\� � �g  form� �g  	type-name� �g  constructor-spec� �g  field-names� ����� � �[[[[ � �f  l-1H5JDRLBnbabw7jk2kqjyg-2944� �f  l-1H5JDRLBnbabw7jk2kqjyg-2945� �f  l-1H5JDRLBnbabw7jk2kqjyg-2946� �f  l-1H5JDRLBnbabw7jk2kqjyg-2947� ����� � �E��� � �g  record-layout� �g  functional-setters� �g  setters� �g  copier� �g  getters� �g  constructor� �g  getter-identifiers� �g  field-identifiers� ��������� � �[[[[[[[[ � �f  l-1H5JDRLBnbabw7jk2kqjyg-2904� �f  l-1H5JDRLBnbabw7jk2kqjyg-2902� �f  l-1H5JDRLBnbabw7jk2kqjyg-2900� �f  l-1H5JDRLBnbabw7jk2kqjyg-2898� �f  l-1H5JDRLBnbabw7jk2kqjyg-2896� �f  l-1H5JDRLBnbabw7jk2kqjyg-2894� �f  l-1H5JDRLBnbabw7jk2kqjyg-2892� �f  l-1H5JDRLBnbabw7jk2kqjyg-2890� ��������� � �E��� � �f  l-1H5JDRLBnbabw7jk2kqjyg-2889� �� � �ERu� � ��OPVWP�PPP��P��� � �@��{ � �@3}~ � �@
�{ � ������ � �|�� � �g  each-any� �=Ɍ� �g  syntax-violation� �� � �� � �f  Wrong number of arguments� �g  identifier?� �� � �� � �[PV � �@4�~ � �� � �� � �f  -source expression failed to match any pattern� �g  record-type-vtable� �� � �� � �g  pwpwpw� �g  default-record-printer� �� � �� � �+�� � �g  set-struct-vtable-name!� �� � �� � �g  vtable-offset-user� �� � �� � �g  %http-server?-procedure� �g  http-server?� �=> � �g  m-AZNFNuzJHj3zfaL9NY031d-944� ��C � �g  t-943� �� � �� � �f  l-AZNFNuzJHj3zfaL9NY031d-949� �� � �E��� � �f  l-AZNFNuzJHj3zfaL9NY031d-946� �� � �ER�� � ���P�WPPPP`ntx � �@A�{ � �g  obj� �g  t-3219� �g  t-3213� �g  t-3214� �g  t-3215� �g  t-3218� �g  t-3217� �g  t-3216� �������� � �g  m-1H5JDRLBnbabw7jk2kqjyg-3220� ��C � ������� �f  l-1H5JDRLBnbabw7jk2kqjyg-3224�f  l-1H5JDRLBnbabw7jk2kqjyg-3225�f  l-1H5JDRLBnbabw7jk2kqjyg-3226�f  l-1H5JDRLBnbabw7jk2kqjyg-3227�f  l-1H5JDRLBnbabw7jk2kqjyg-3228�f  l-1H5JDRLBnbabw7jk2kqjyg-3229�f  l-1H5JDRLBnbabw7jk2kqjyg-3230� �	E�  �
g  	copier-id�
 �f  l-1H5JDRLBnbabw7jk2kqjyg-3211� �Eu �g  	ctor-name� �f  l-1H5JDRLBnbabw7jk2kqjyg-3203� �Eu �� �f  l-1H5JDRLBnbabw7jk2kqjyg-3201� �Eu �g  layout� �f  l-1H5JDRLBnbabw7jk2kqjyg-3199� �Eu �g  
immutable?� �f  l-1H5JDRLBnbabw7jk2kqjyg-3197�  �!Eu  �"g  field-count�#" �$f  l-1H5JDRLBnbabw7jk2kqjyg-3195�%$ �&E#u% �'g  
getter-ids�(' �)f  l-1H5JDRLBnbabw7jk2kqjyg-3192�*) �+E(u* �,g  	field-ids�-, �.f  l-1H5JDRLBnbabw7jk2kqjyg-3189�/. �0E-u/ �1g  predicate-name�2g  
field-spec�3���12 �4[[[[[[ �5f  l-1H5JDRLBnbabw7jk2kqjyg-3176�6f  l-1H5JDRLBnbabw7jk2kqjyg-3177�7f  l-1H5JDRLBnbabw7jk2kqjyg-3178�8f  l-1H5JDRLBnbabw7jk2kqjyg-3179�9f  l-1H5JDRLBnbabw7jk2kqjyg-3180�:f  l-1H5JDRLBnbabw7jk2kqjyg-3181�;56789: �<E34; �=��P�WP	PPPPPPPP!P&P+P0<�� �>@�={ �?> �@g  and�A@@={ �Bg  struct?�C@B={ �DC> �Eg  eq?�F@E={ �Gg  struct-vtable�H@G={ �IH> �J[�P� �K@3J~ �LFIK �MADL �N�?M �O[P� �P@�O~ �Qg  throw-bad-struct�RQ �SQ �Tg  http-socket�Ug  %http-socket-procedure�Vg  free-id�Wg  
%%on-error�Xg  m-AZNFNuzJHj3zfaL9NY031d-956�YXC �ZY �[f  l-AZNFNuzJHj3zfaL9NY031d-958�\[ �]ERZ\ �^YP]WPPPP`ntx �_@W^{ �`V_ �a`> �bg  %%type�cg  t-3002�dg  t-3003�eg  t-3004�fg  t-3005�gg  t-3006�hg  t-3007�ig  t-3008�jcdefghi �kg  m-1H5JDRLBnbabw7jk2kqjyg-3009�lkC �mlllllll �nf  l-1H5JDRLBnbabw7jk2kqjyg-3013�of  l-1H5JDRLBnbabw7jk2kqjyg-3014�pf  l-1H5JDRLBnbabw7jk2kqjyg-3015�qf  l-1H5JDRLBnbabw7jk2kqjyg-3016�rf  l-1H5JDRLBnbabw7jk2kqjyg-3017�sf  l-1H5JDRLBnbabw7jk2kqjyg-3018�tf  l-1H5JDRLBnbabw7jk2kqjyg-3019�unopqrst �vEjmu �wg  getter�xg  index�ywx �zf  l-1H5JDRLBnbabw7jk2kqjyg-3000�{f  l-1H5JDRLBnbabw7jk2kqjyg-3001�|z{ �}Ey\| �~�'
 �[[[ ��f  l-1H5JDRLBnbabw7jk2kqjyg-2995��f  l-1H5JDRLBnbabw7jk2kqjyg-2996��f  l-1H5JDRLBnbabw7jk2kqjyg-2997����� ��E~� ���P]WPvPPP}P��� ��@b�{ ��V� ��=a�> ��g  ck��g  err��g  s���� ��YY ��f  l-AZNFNuzJHj3zfaL9NY031d-961��f  l-AZNFNuzJHj3zfaL9NY031d-962���� ��E��� ��Y�P]WPPPP`ntx ��@��{ ��g  quote��@��{ ��[�P] ��@3�~ ���� ��� ��g  %%index��@��{ ��V� ��=a�> ��f  l-AZNFNuzJHj3zfaL9NY031d-966��f  l-AZNFNuzJHj3zfaL9NY031d-967���� ��E��� ��Y�P]WPPPP`ntx ��@��{ ��@��{ ���P] ��@
�~ ���� ��� ��g  %%copier��@��{ ��V� ��=a�> ��f  l-AZNFNuzJHj3zfaL9NY031d-971��f  l-AZNFNuzJHj3zfaL9NY031d-972���� ��E��� ��Y�P]WPPPP`ntx ��@��{ ��@��{ ��g  %%<http-server>-set-fields��[�P] ��@��~ ���� ��� ��g  t-955��� ��f  l-AZNFNuzJHj3zfaL9NY031d-976��� ��E�Z� ��Y�P]WPPPP`ntx ��@A�{ ����P]WPvPPP}P��� ��@��{ ��� ��g  if��@��{ ��@E�{ ��@G�{ ���� ��[�P] ��@3�~ ����� ��g  
struct-ref��@��{ ���P] ��@
�~ ����� ��@Q�{ ��@��{ ��@T�~ ���� ����� ������ ����� ��[P] ��@U�~ ��g  http-poll-idx��g  %http-poll-idx-procedure��g  m-AZNFNuzJHj3zfaL9NY031d-983���C ��� ��f  l-AZNFNuzJHj3zfaL9NY031d-985��� ��ER�� ���P�WPPPP`ntx ��@W�{ ��V� ���> ���P�WPvPPP}P��� ��@b�{ ��V� ��=��> ���� ��f  l-AZNFNuzJHj3zfaL9NY031d-988��f  l-AZNFNuzJHj3zfaL9NY031d-989���� ��E��� ����P�WPPPP`ntx ��@��{ ��@��{ ��[�P� ��@3�~ ���� ��� ��@��{ ��V� ��=��> ��f  l-AZNFNuzJHj3zfaL9NY031d-993��f  l-AZNFNuzJHj3zfaL9NY031d-994���� ��E��� ����P�WPPPP`ntx ��@��{ ��@��{ ���P� � @�~ ��  � �@��{ �V �=�> �f  l-AZNFNuzJHj3zfaL9NY031d-998�f  l-AZNFNuzJHj3zfaL9NY031d-999� �	E�� �
�	P�WPPPP`ntx �@�
{ �@�
{ �[	P� �@�~ � � �g  t-982� �f  l-AZNFNuzJHj3zfaL9NY031d-1003� �E� ��P�WPPPP`ntx �@A{ ��P�WPvPPP}P��� �@�{ � �@�{ �@E{ �@G{ � �[P� � @3~ �!  �"@�{ �#P� �$@#~ �%"$ �&@Q{ �'@�{ �(@�~ �)'( �*&) �+!%* �,+ �-[P� �.@�-~ �/g  http-poll-set�0g  %http-poll-set-procedure�1g  m-AZNFNuzJHj3zfaL9NY031d-1010�21C �32 �4f  l-AZNFNuzJHj3zfaL9NY031d-1012�54 �6ER35 �72P6WPPPP`ntx �8@W7{ �9V8 �:9> �;�P6WPvPPP}P��� �<@b;{ �=V< �>=:=> �?22 �@f  l-AZNFNuzJHj3zfaL9NY031d-1015�Af  l-AZNFNuzJHj3zfaL9NY031d-1016�B@A �CE�?B �D2CP6WPPPP`ntx �E@�D{ �F@�D{ �G[CP6 �H@3G~ �IFH �JI �K@�;{ �LVK �M=:L> �Nf  l-AZNFNuzJHj3zfaL9NY031d-1020�Of  l-AZNFNuzJHj3zfaL9NY031d-1021�PNO �QE�?P �R2QP6WPPPP`ntx �S@�R{ �T@�R{ �UQP6 �V@	U~ �WTV �XW �Y@�;{ �ZVY �[=:Z> �\f  l-AZNFNuzJHj3zfaL9NY031d-1025�]f  l-AZNFNuzJHj3zfaL9NY031d-1026�^\] �_E�?^ �`2_P6WPPPP`ntx �a@�`{ �b@�`{ �c[_P6 �d@�c~ �ebd �fe �gg  t-1009�hg �if  l-AZNFNuzJHj3zfaL9NY031d-1030�ji �kEh3j �l2kP6WPPPP`ntx �m@Al{ �n�kP6WPvPPP}P��� �o@�n{ �po �q@�n{ �r@En{ �s@Gn{ �tso �u[kP6 �v@3u~ �wrtv �x@�n{ �ykP6 �z@	y~ �{xoz �|@Qn{ �}@�n{ �~@/u~ �}~ ��|o ��qw{� ��mp� ��[P6 ��@0�~ ��g  each��>> ���� ��>����>����>����g  %%set-fields��g  dummy��g  check?��g  expr�����w� ��g  m-AZNFNuzJHj3zfaL9NY031d-1037���C ������� ��f  l-AZNFNuzJHj3zfaL9NY031d-1042��f  l-AZNFNuzJHj3zfaL9NY031d-1043��f  l-AZNFNuzJHj3zfaL9NY031d-1044��f  l-AZNFNuzJHj3zfaL9NY031d-1045��f  l-AZNFNuzJHj3zfaL9NY031d-1046������� ��E��� ��� ��f  l-AZNFNuzJHj3zfaL9NY031d-1039��� ��ER�� ��g  t-3033��g  t-3035��g  t-3034����� ��g  m-1H5JDRLBnbabw7jk2kqjyg-3036���C ����� ��f  l-1H5JDRLBnbabw7jk2kqjyg-3040��f  l-1H5JDRLBnbabw7jk2kqjyg-3041��f  l-1H5JDRLBnbabw7jk2kqjyg-3042����� ��E��� ��f  l-1H5JDRLBnbabw7jk2kqjyg-3030��f  l-1H5JDRLBnbabw7jk2kqjyg-3031��f  l-1H5JDRLBnbabw7jk2kqjyg-3032����� ��E~� ����P�WP�PPP��� ��@��{ ��[�P� ��@3�~ ��@T�~ ��@��~ ��@/�~ ����� ��g  map��� ��� ��g  list��g  set-http-poll-idx!��g  %set-http-poll-idx!-procedure��=>> ��g  m-AZNFNuzJHj3zfaL9NY031d-1057���C ��g  t-1055��g  t-1056���� ���� ��f  l-AZNFNuzJHj3zfaL9NY031d-1062��f  l-AZNFNuzJHj3zfaL9NY031d-1063���� ��E��� ��� ��f  l-AZNFNuzJHj3zfaL9NY031d-1059��� ��ER�� ����P�WPPPP`ntx ��@A�{ ��g  t-3067��g  t-3068���� ��g  m-1H5JDRLBnbabw7jk2kqjyg-3069���C ���� ��f  l-1H5JDRLBnbabw7jk2kqjyg-3073��f  l-1H5JDRLBnbabw7jk2kqjyg-3074���� ��E��� ��g  setter��cw� ��f  l-1H5JDRLBnbabw7jk2kqjyg-3061��f  l-1H5JDRLBnbabw7jk2kqjyg-3062��f  l-1H5JDRLBnbabw7jk2kqjyg-3063����� ��E�� ��2x ��f  l-1H5JDRLBnbabw7jk2kqjyg-3052��f  l-1H5JDRLBnbabw7jk2kqjyg-3053���� ��E�\� ��g  field-specs���� ��f  l-1H5JDRLBnbabw7jk2kqjyg-3048��f  l-1H5JDRLBnbabw7jk2kqjyg-3049���� ��E�\� ����P�WP��P�P��� ��@��{ ��g  val��@��{ ���� ��@��{ ��@E�{ ��@G�{ ���� ��[�P� ��@3�~ ����� ��g  struct-set!��@��{ ���P� ��@�~ ������ ��@Q�{ ��@��{ ��@��~ ���� ����� � ���� ���  �[P� �@�~ �g  POLLHUP�g  POLLERR�g  *error-events*�g  POLLIN�g  *read-events*�	g  *events*�
g  hostS�

��g  familyS���g  addrS�	��g  portS�	��g  socketS�	�� �g  AF_INET�g  	inet-pton�g  INADDR_LOOPBACK�g  listen�g  	sigaction�g  SIGPIPE�g  SIG_IGN�g  make-empty-poll-set�g  poll-set-add!�g  	http-open�g  write-response� g  build-response�!g  versionS�"
��#g  codeS�$g  headersS�%g  content-length�&%
��'& �(g  bad-request�)g  poll-set-revents�*g  
<poll-set>�+%* �,%* �-g  poll-set-nfds�.g  accept�/g  poll-set-port�0g  setvbuf�1g  _IOFBF�2g  	SO_SNDBUF�3g  throw�4g  	interrupt�5g  poll-set-remove!�6g  eof-object?�7g  	peek-char�8g  
close-port�9g  with-throw-handler�:g  read-request�;g  read-request-body�<g  catch�=g  format�>g  current-error-port�?f  In ~a:
�@g  port�A(@ �Bg  print-exception�C8@ �Dg  	http-read�Eg  
<response>�FE �GE �Hg  response-version�Ig  response-code�Jg  memq�Kg  close�Lg  response-connection�Mg  
keep-alive�Ng  keep-alive?�Og  response-port�Pg  bytevector?�Qg  write-response-body�Rg  error�Sf  Expected a bytevector for body�Tg  force-output�Ug  
http-write�Vg  
http-close�Wg  server-impl�X!W �Y!W �C 5h /  /  ] 4	
'5 4* >  "  G   +,-./01      h@   �   ]4
54>  "  G  4 >  "  G  C�       g  family
		@ g  addr		@ g  port			@ g  sock			@  g  filenamef  web/server/http.scm�
	'
��		(	��		(	��		)	��	&	*	�� 		@	  g  nameg  make-default-socket� C2R3       h   �   ] � C  �       g  socket
		 g  poll-idx		 g  poll-set			  g  filenamef  web/server/http.scm�
	-
�� 			  g  nameg  %make-http-server-procedure� C4R4789<?�     h   S   ]  C  K       g  t-924
		 g  t-925		 g  t-926			  			   C��8� h   V   ]L 6    N       g  a
		  g  filenamef  web/server/http.scm�		-
�� 		   C=�  h   F   ] L 6>       g  filenamef  web/server/http.scm�		-
�� 		
   C�    h      ] C          		
   C��        hp   �   ]4 5$  @4 5$   O @4 5$  4 O ?$  @	
 6	
 6         g  x
		n g  tmp		n g  tmp		"	n g  tmp		>	n  g  filenamef  web/server/http.scm�
	-
�� 		n   C58R���3ި  4� 3>  "  G   	�4i�  3R3      h   {   ] �$   ��CC      s       g  obj
		  g  filenamef  web/server/http.scm�
	-
�� 		  g  nameg  %http-server?-procedure� C�R47�9<�N       h   -   ]  C      %       g  t-943
		
  		
   C����       h   V   ]L 6    N       g  a
		  g  filenamef  web/server/http.scm�		-
�� 		   C=�  h   F   ] L 6>       g  filenamef  web/server/http.scm�		-
�� 		
   CP   h      ] C          		
   C��        hp   �   ]4 5$  @4 5$   O @4 5$  4 O ?$  @	
 6	
 6         g  x
		n g  tmp		n g  tmp		"	n g  tmp		>	n  g  filenamef  web/server/http.scm�
	-
�� 		n   C5�R3ST        h   x   ] �&   
�C 6p       g  s
		  g  filenamef  web/server/http.scm�
	-
�� 		  g  nameg  %http-socket-procedure� CUR47T9<���    h   :   ]��C     2       g  err
		 g  s		  			   C��� h   :   ]��C     2       g  err
		 g  s		  			   C��� h   :   ]��C     2       g  err
		 g  s		  			   C��     h   -   ]  C      %       g  t-955
		
  		
   C��T�      h   V   ]L 6    N       g  a
		  g  filenamef  web/server/http.scm�		-
�� 		   C=�  h   F   ] L 6>       g  filenamef  web/server/http.scm�		-
�� 		
   C�   h      ] C          		
   C��        h�   �   ]14 5$  @4 5$  @4 5$  @4 5$  	@4 
5$   O @4 5$  4 O ?$  @ 6 6     �       g  x
	 � g  tmp	 � g  tmp		" � g  tmp		9 � g  tmp		P � g  tmp		g � g  tmp	 � �  g  filenamef  web/server/http.scm�
	-
�� 	 �   C5TR3S�   h   z   ] �&   �C 6r       g  s
		  g  filenamef  web/server/http.scm�
	-
�� 		  g  nameg  %http-poll-idx-procedure� C�R47�9<���  h   :   ]��C     2       g  err
		 g  s		  			   C�� h   :   ]��C     2       g  err
		 g  s		  			   C h   :   ]��C     2       g  err
		 g  s		  			   C�,     h   -   ]  C      %       g  t-982
		
  		
   C����      h   V   ]L 6    N       g  a
		  g  filenamef  web/server/http.scm�		-
�� 		   C=�  h   F   ] L 6>       g  filenamef  web/server/http.scm�		-
�� 		
   C.   h      ] C          		
   C��        h�   �   ]14 5$  @4 5$  @4 5$  @4 5$  	@4 
5$   O @4 5$  4 O ?$  @ 6 6     �       g  x
	 � g  tmp	 � g  tmp		" � g  tmp		9 � g  tmp		P � g  tmp		g � g  tmp	 � �  g  filenamef  web/server/http.scm�
	-
�� 	 �   C5�R3S/   h    z   ] �&   	�C 6       r       g  s
		  g  filenamef  web/server/http.scm�
	-
�� 		  g  nameg  %http-poll-set-procedure� C0R47/9<>EJ  h   :   ]��C     2       g  err
		 g  s		  			   CMSX h   :   ]��C     2       g  err
		 g  s		  			   C[af h   :   ]��C     2       g  err
		 g  s		  			   C��     h   .   ]  C      &       g  t-1009
		
  		
   C��/�     h   V   ]L 6    N       g  a
		  g  filenamef  web/server/http.scm�		-
�� 		   C=�  h   F   ] L 6>       g  filenamef  web/server/http.scm�		-
�� 		
   C�   h      ] C          		
   C��        h�   �   ]14 5$  @4 5$  @4 5$  @4 5$  	@4 
5$   O @4 5$  4 O ?$  @ 6 6     �       g  x
	 � g  tmp	 � g  tmp		" � g  tmp		9 � g  tmp		P � g  tmp		g � g  tmp	 � �  g  filenamef  web/server/http.scm�
	-
�� 	 �   C5/R47�9<������      h    v   ]45�����C   n       g  dummy
		 g  check?		 g  s			 g  getter			 g  expr			  			   C��   h(   �   ]	4 5$  @ 6      �       g  x
		" g  tmp		"  g  filenamef  web/server/http.scm�
	-
�� 		"  g  
macro-typeg  syntax-rules�g  patternsg  check?g  sg  getterg  expr g  ...   C5�R3S�     h    �   ] �&   �C 6      �       g  s
		 g  val		  g  filenamef  web/server/http.scm�
	-
�� 			  g  nameg  %set-http-poll-idx!-procedure� C�R47�9<�       h   B   ]  C    :       g  t-1055
		 g  t-1056		  			   C���� h   V   ]L 6    N       g  a
		  g  filenamef  web/server/http.scm�		-
�� 		   C=�  h   F   ] L 6>       g  filenamef  web/server/http.scm�		-
�� 		
   C   h      ] C          		
   C��        hp   �   ]4 5$  @4 5$   O @4 5$  4 O ?$  @	
 6	
 6         g  x
		n g  tmp		n g  tmp		"	n g  tmp		>	n  g  filenamef  web/server/http.scm�
	-
�� 		n   C5�Rii�RiRii�	R2	3   h�   g  -  /     0   3  #   #  #   $  4 5"  #  �#  454 �>  "  G  4	>  "  G  4
5 4>  "  G  
� C      _      g  host
	 � g  family	 � g  addr		 � g  port		 � g  socket		 � g  poll-set	 � �  g  filenamef  web/server/http.scm�
	9
��	2	<	��	3	=	��	U	@	��	b	A	��	w	B	�� �	C	�� �	C	�� �	D	�� �	E	�� 	 �

g  hostS
�g  familyS�g  addrS	�g  portS	�g  socketS	�   g  nameg  	http-open� CR !"#$'    h    �   ]4�5 6      �       g  port
		  g  filenamef  web/server/http.scm�
	G
��		H	��		H	,��		I	,��		H	��		H	�� 		  g  nameg  bad-request� C(R3S/)$,-./01./2	�3456789:;  h   y   ]4L 5 L  4 5Dq       g  req
			  g  filenamef  web/server/http.scm�
	|	��		}	��			}	��	 �	��		~	�� 		
   C<(    h   P   ] L 6H       g  filenamef  web/server/http.scm�
 �	��	 �	 �� 		
   C=>?AB     h0   j   - 1 3 445 >  "  G  45  6b       g  k
			0 g  args			0  g  filenamef  web/server/http.scm�
 �	�� 			0
   C8       h   P   ] L 6H       g  filenamef  web/server/http.scm�
 �	��	 �	 �� 		
   C=>?CB     h0   j   - 1 3 445 >  "  G  45  6b       g  k
			0 g  args			0  g  filenamef  web/server/http.scm�
 �	�� 			0
   C   h8   |   - 1 3 4L O >  "  G  L O 6       t       g  k
			1 g  args			1  g  filenamef  web/server/http.scm�
 �	��	
 �	��	1 �	�� 			1
   C�      h�  �  ]) �&  	 	�"  	4 5" �45
�$  �
�$  34>  "  G  �&  �"  	45�"����
�$  �4	4
554�>  "  G  4�0 >  "  G  4�>  "  G  4>  "  G  �&  �"  	45�"�� �&   �"  4 >  "  G  6
�$  	�"���45� �&   �"  4 >  "  G  4455$  4>  "  G  �"��yO O 6 �&   �"  	4 5"��F   �      g  server
	� g  poll-set	� g  idx		#� g  revents		,� g  client	 � g  port	M� g  val	R  g  filenamef  web/server/http.scm�
	M
��		N	��		N	��	#	O	��	$	P	��	,	P	��	1	R	
��	6	Q	��	9	U	��	>	T	
��	?	W	��	S	X	��	k	X	��	q	X	��	v	Y	��	w	Y	��	|	T	
��	}	a	�� �	a	"�� �	a	�� �	a	�� �	c	�� �	c	�� �	c	�� �	e	�� �	e	�� �	e	<�� �	e	�� �	f	�� �	f	&�� �	f	�� �	g	�� �	h	�� �	h	��	h	��	[	��1	\	��3	\	��6	i	
��;	Q	��>	k	��D	k	
��E	o	��M	o	
��R	r	'��R	r	���	t	���	t	���	t	���	s	���	v	���	w	���	w	���	z	���	O	���	O	���	O	�� :	�  g  nameg  	http-read� CDRGSHIJKLM 	   h�     ] �&   
�"  	4 5 �&   �"  	4 5��$  "   �&   �"  	4 5��$  C��$  4��$  44 55�C
�$  4 56CCC     w      g  response
	 � g  v	 � g  t		<	j g  key		q � g  key		~ �  g  filenamef  web/server/http.scm�
 �
��	 �	��	 �	��	! �	��	< �	��	< �		��	L �	��	g �	��	n �	��	q �	��	q �		��	~ �	��	~ �	�� � �	�� � �	�� � �	%�� � �	�� � �	�� � �	�� � �	�� � �	%�� � �	�� 	 �  g  nameg  keep-alive?� CNRGSOPQRSNT3/	8     h�   �  ]45�&  		�"  	45$  ;45$  4>  "  G  "  4>  "  G  "   4	5$  E4
>  "  G  4 �&  	 	�"  	4 5>  "  G  "  4>  "  G  D  �      g  server
	 � g  client	 � g  response		 � g  body		 � g  response		 � g  port		( �  g  filenamef  web/server/http.scm�
 �
��	 �	��	 �	��	 �	��	( �	��	0 �	��	1 �	��	; �	��	< �	��	T �	��	X �	��	_ �	��	l �	��	v �	��	w �	�� � �	�� � �	�� � �	�� � �	�� � �	�� 	 �	  g  nameg  
http-write� CUR3S/85,-       hp     ] �&  	 	�"  	4 5"  -
�$  #44�5>  "  G  �"���C�&  �"  	45"���      g  server
		p g  poll-set		p g  n		#	P  g  filenamef  web/server/http.scm�
 �
��	 �	��	 �	��	# �	��	& �	
��	+ �	��	, �	��	/ �	��	6 �	3��	8 �	��	= �	��	H �	��	N �	��	P �	��	S �	��	p �	�� 		p  g  nameg  
http-close� CVRiDiUiVi Y �  RC  '      g  m
		( g  rtd
�	 g  open
.�/ g  read.�/ g  write	.�/ g  close	.�/  g  filenamef  web/server/http.scm�		
��[	'
��1	-
��	4	��	4
��	5
�� 	6	��$	6
��{	9
��\	G
��((	M
��*� �
��-) �
��.� �
��.� �
�� 	/
   C6 