ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ��Y �=�r�r���d��&)W*�}�r&;㝑DR�dy����ZcK�.�Ǟ����D�"4�H�]:�O8U���F�!���@^��Ւ/c[���~�%��h ݍ�h�Xk!;��v;(�1a�ac�������a@ ���4.	��)DeI|"FEE�����r1&��'@x����q��׆]�Y�w��_)t����ϥ�� �kh���8 ��7�g��r�a!�Ԃm�9z�m� e�~�&�Ȏ�O�C�`�u|� ���aCؤ��2du[md�C��^a��)�����|n�< �r��A[w�M�n�|���\�C�����`��٪�6,��bdd��4)�y�*U�f#�V,�U*��u�H%ĺ���݆��jB�B������'���y"&�\"R�6�&��X7�:�نv]�u�h�ѡ�i�����,��bX���K��u��[�͊�m�i�6It$<�m2y:�E�ε�m�=:�QA��:��B�8ǋGtD˳M�z��h��H@9��a�c"ڃ͸�����`�P\��+��p��E��j;�|��ٳb���v�3���M���k0�	����7��P>��_<tt���_}����w'��R���:q�D]"̷��dٹ�A�P�M`y�yo0�8�,����bK����3����ȶ�9\V���� �����7�!uCt�'�y�6���+��?
#�/*<Q��)������9��"�F��/�a�y�6��+��_�$:�bTeI�����R|��/�~�V��&�`����� ����M�$�|�T+ۧ���r*�N�0��:~�tz:�951$�/̀��a��Sݧ��Y�_������/��j-�@�3[�;�������P��c�(D�9������/�Ns�˽*l����Ea�/�=�Af٠���b@G��i@�d��E&�Г0�v:.�x6ݎ�vl�]ʚk{�و<7\l�GG �c������ݿCv��Iӫѝkd�����i}.؉��s�؞=hJ5|�LCC���V��4QH
��	ن��>?��˚���ք��:���Gԡ�|���,��v�w9��}g<5�0�����e�|�3; ���Y�R�D�ǽ%����)PJ����!+5.���G�n�#2����̓aR#�N��`�d|>�f���f����x��'����K��E�Ɵ���j��������zy��Y��M肖a� Z:�Qw)D��,˰�B7�丸�b���}q�����8 �q�3���&�E�A~�x|xMIZ� ���Cڣ�!i�j;< ?H?��Hp���d���A�����K[/�N��M�v0� T���(fG�'G��%s t@��Qؘ폙������]ǰA9�`�'�%�1����}x������̼U���p}\��"��	�g21��4}s�	e�>�X�>�}@.Jȕ<�e�(�:&�n�����W�[�������L����4�&�̳?��?:[/�p� l���@>s�6Ưs���N[@���d���0�Q�M>c8����֙:��f#�z�z�8�����W+0�:7ܠ9P�tl��
����
҃��P���OL�����:���a�����ڸ���H_�P�?&�J4*Q����/|?)=>��3�l���OϜu��;fc�稷��a�w�<ۦ�� ���\:_��s�U���J��߯n���&T�?�]9�<v9�<xNYb�r�x�Y5YΧN3�J~���|0v��w
�,�����xmڀ+D��i�����q�t�b��"�
<6��0Kw*W��T�r���/d�����B�ǻ��"��;�W�0U{KT�>P��F[���N%>�|Ƣ��߃w����o�	<�����$̹\��&(W�kא̓�~�^3���.�::;�S��!#�7�#����"��X~Z��/g�c�5�sp�p'���g5���'��be��+��ˆ��?h���I���0�����J������O���Z�60,2!�	B�����9�����`e_Y�{���������?�B,���\�<�l�s/)����?���QPV�����'(������?� Q$"@�?UV�K������كێ�mc��؆�/D�mh�N��;��^��� B���\�f�Ѿ�V��M�'N�qQ��!�k(pFW��K� T�%������pp+d�er���5hҘ'qO�6�u�ɻb��qĳa{�@�|���ȏ�`!�L�%&�owg^!S��_#�c�C��p��{@3�V�	����	
�i���љ�?����R��k��� ą��B":'�!��]����ړ���T������Ә�BX���!�{���ܻ��=��צ�|���V��p������	T�%E^�X
<��/�dQ�m��tAmĄ���'�����Q=�-�J������1�7����������}��Q^�sw�>���<����;}���4�	�xH�0��D���"�PgUN�̱�4��e�i���`�5tmA�w�����=��e�O���vы��K3�"en^�K����`�&v\?�H�"�����1UG�_��>7���F�I�1�hn����g3d�ˆ1Ua"�tWg��<���+dצ��9iʢ)�e�� �܀#bD�̻�4�1ЄY0�H�>:QYtc����4��G��������}Bw?���U������l�|�v�oj�N�5�%.�̿�(���[p��5w�}����~��������_�?����3��M���F]5QN�z�.k�D�^KH��H���DT֠�P	��P�چ�����ܟ��f	��k�������_�#�ƭ}��%]�֞|���R�r��^{����[�`����뫵?5M�߿��1��~��9k���w���7�����'���G���_��o	�ߌ
&qʈFL�C������sϼw���ީ�[���� z�KL���/>q�G9&o���_�:�2=\��%�e�ǚ�J��N�F;�a�Qz���d�`@?�O�^�g:]�o^�Ѡ�qy��q�Eek��juA�oD���F�5���%d)����С�EeA��F&jb��e%N�0F�.y�Z�� �N�B2��A*S����ZͰ��V!�O��R)UK5�^>�6�e���Y�ŗ}=����۸�3-��K5��;�$q&dnO���
j+���d��:<,�g.�r�Q<$���V�Y˙�Z��2��3���UӇ䙑̽��v�;�̋ci�<WU�����%�'��m�Y{�tN*�YMη�*�q
ՌTl��v�s1{�M�X�j��Y^*T��^5/Ѳ3V&��[Gg�Z���R���a�����\d�2p�w�da�$ext���J縚9*$K~����ց�����r��j�z!)0��;*�]x��d,�BE1Q.�j�ss�]�֪�2��B.��������R��s/��
y5��6vΓ%1�:�T�x�/�5�w��7�&�pT��In[���øY>��u'��a(��I���Ko+�S��˱9��5z;g�jr���d.�z��IFz%:�ۍ�Z�c�].$��FF=S�Bʡ���R���Q�ɶ}�x2�L����n�����i�ý=[HecCz�l)�
*���`Jj!s�ʗR��S���R���Z���"�%"M��e<�WP�::�&�)=��7*�N��o�:��Lf�B"�U�[o��P0�)9��Ń����b"�)��?p��]l5v��H6f����~� ���#_@Ř{v��)�c�:����J������M�����%�������g��E�X�ˀ	?i��?$�����o�B>�M�d��5:�z��P�RC����6"	�U�}˝쩇BE|���#���4�.�;%K���J�j��A��)�.�0yq(�S&~YC�o9��u�/����5�rp�-�F�yd`�U�$$AM����nz�*�6J������|W;��G�����_���+�����������'���_���+���������ͧ&��l���o�)�4:
I�%-]j��ٙl� V�o
�G/��M����o9��=�Z�y哷�a��hb��Î���ۺp-�m��=q�1z�Bb�c5�y�V[[��,g�{�~;�	��︘�ԍF�o�+a7�,.K3翊L����?><)���,z2�,�ov'T�eZ�2br����4s?�6�맽�g�uٛ`�����������H{v��A�Qݰ1��4�Z�;�v@Z�A��QK��:�!�,M�CO�a�SzA�@;��o�- ��mhX�`"���?t۔"_� ��b!@_;�Q5d�A���D.	������趱��?���򰿷�b��("<���!>��2�cɝ|l�}4���q�n�e:e�E���]CtN����Մ��D�
�سz�B��L�� �8ߣ7{�b��H�"2|�E�|m�)tX��Ahh۰O���/�6�Chg�0.�Ӷ��DP�d�0�@ߞ�h /��g���:�6���/�S�p���^餇'�Șa˗�{�d@s��B(��t�&�� &>�m舚��i�uSEҿd��b���1�	oN�ص�_^�����/Ƀ-� 7m�^~ 퓱�B�#�۸͘�}���P"*��
���PA�"�~4ў����_ǘ�mR�>�Iɂ�_�+�3Np�8�V&�	�pr�QS!zWL�R�Ȳ�����R��/ϸ5���q�po|{zڀ�T5��F�)aWk �:vh5�\6�A&xp��Zbb�"����M��Z5<)�YnH��1�����%���G9d+!x�*���/��|E,󵥣s�B���n�Tߣ�OZ��ɵ=���SUy1����
1��mdW}cH�&�n{�G����E�V���v�������i�ѰQ���{��rM�e�N�V!C���3F��6M��H��H�S��q���M?c���t�7�2*��n�,��`@>��4c�����N�-�X�1�NI(][�4���d5���4�
��y$�Xwg&�M���w-1�ci�{�i
w���N?�0C��t�.��#��s��c'q*��y�(9����<*v�$tY �h	�����Y��alF Do���s���ǭ�7uQ紺n�}���������]uhkh�	breW��q2�m�i"r���%!��#�/��Y������_��ǽ�)���������7���_B��#����qd��������ͣA��[�F6�I�)�~FґXDQeL&#J���8�E�hK��q��h���q�l�	J�b
NTG��	%b�B���Ї�����[?��������tn忠~��ơ����a���B��>��
Ek�����������{��������� ��X.���A���z����o�ݛ��v���+��:��bE.���b�ʱ�g�i�2�+�1�l�{����"ǜ�K��Bn���UH ]�ٶS�'w����Ȏ�\�?EvgdԤ��sK��s�H��M�~�p��g���%�qh�ѫ�X-���[c�Q������5�{b�a%�.�[�d�얆�^k����L,���3��s�{�T�F�Z�ʴA�M�dY�.��!�<w�(S�3���	�n�\��7���if���E͢ߤLK�h��S|i�zB�놮�L2�)�J��~�-��ܬ�_X35U��vF�'�:b�8��V`�i�e��"����=?"�H!l��X�3KN�� �ْC�Y��n���M�"j��4a�S���/H3CY�IϊB}��6��No|Anb��]e������+�&ې��h"�xL���Z�BO��c2a(m��<�N�	!U����g�r�,1�a���[�����ɩ0V%)v�X�(����-vy���r�]���]���]���]���]q��]a��]Q��]A��]1��]!��]��.�������QN3D�M�3�p-��9�v�}����^���K��嚘^J�j�������XSR�%t�]T��ƭUt��TO�J� @���&�J�N� ����:�=b�T43��Y"{��sS�6kR�}��gIa�����R��F�@0�&�d�"�͒�+�B}���5�;T��^� ��y�m���q������+|n���	C'�y�9_Zx;���/�K�O�I��xG�|2N�������7�
g%��Z7�-�����T?!0�l��qz.�'T>�?�jt�Y�O�D�:���w:��,F�+�̿���������C��Bo��~�赇o��[����V7�n^»7v���ϐ��-���ۛ��H�ڋ�'����:�����͇��kP���^<�yܡБݗ7B_��w�b�?� �>
}��п~	|�
�����5���A�B�������,��E�"�t�`�fy���[[��h�N+���Η���S�t~������t�[`y(���X͢�<=Ʌ��jJ.�]E�ﺢ�27%p]d+����P`��$Fb�mWY�Jq�,k<f1���t�]��ttJ'��17.���"�dmv��x.?��V#}��BS;��i&1h�mc���y�d�X������&�3������)�:�e��I$�^N��6x�;�1��=�J�iTL@ZP�nQc����eЮ�T:��D�85���@��H�G�#4�K�YS��\��X����.��z��K��`P�1I�G�~=o[]�j�EcЯXm�6B�b+��1��up��������0[�3$�D��NB�׿�x��2M�-�P.62� TEq���l��N{����p�_Y����M9�d����r=O?">W�d�����5�s~�����>��	�3�fU������m��cw���L��m�%���>-�n��r��,���jɂ9��z![ )C��M�8��\=�״be�֖�>G"l)��M�4h�q{suQ
�0�%��h3����E.'���2"c9�2��	�a�S�Y��D�FL�6��Ԩ[,�B7��Ϻzgz��.N�=���"[���D*#n��]a�(�Q���뱂�jV�L�֗*ʘϔ���F:�5�/�"���J��0]N"c�t��O�5��2��pa�|9����)Q�F�̲���l⿼�'rP$��"s�Aq<�kѩ��٬ғ#�Ub���*���b\E2Oz�����FLYP� �=��	����T&���I	��BA�{��J93�+��ib|l�z��#�T����Oa�1�0�N��͚Ų�%��4�e���9�b�,���JeT��"�26�iHlٛ �r[��xe�B�V��"r�/�KKV�1����M��s����	җI1-mH^_��D/��c,�%3T�5��R�1M�����3 �NP*>*�;LV��2k��l*Z���s��Ě<ʑ�Bj6۵x9��y�*f�����.��зm�a�.}'�v�t���x�2���|�B����-��9ќ�b�#/��_D~��CcjH��z7�&�1�G~�G�O����z/����g���=�y����H����;�7��+��"�`�7���k��C�.^ n�M�Z��<}������ѻ#��� ���+2�q>F~���M�-P��8�8uG�k�o���]wqE����!*����>?�C�^��E�eV��ל��.��� �Ȝ���5��0:����<|��Oz9�_��>z�	���Gݿ�9��Q���5����΀ ��V��|%ܳ3����#�E�)�*���<PM�Tv�����Uo��f_���'0���ϕ�)�3��U?��vW@��wO�o8Ua�e�ѥ�e�p?]���o�Y׋llݮ��V] �_��bNvt�dG�~���Sx{��;�����@�N���ӸD�:�"�=,�a�1
@>:�A�)���t?Qa��� �3���{PїA������a���&ö�� �1^0�{�$̰�Mu%<Tm��]n}�~e��Wkjz2 ��l>_�� �jd�0	 ��x�xK|v�'�]����s"�����!P���o���A��h��p�MFC�_f�:�M����`�`?yE��Wag
Va��i�
E�.d,�=wh��m�od�v�ʜ�N�k��Б��1�k�`�l�;���ɸ�ы�'�� �aa���X�O¥�]�ȋ,_BV���_�����	?3 �L�Xݜ�M��ͧ�u�y�����h�lH؏���V������ůG~�����&x�d22��k�������Е��� �N�
��`iA�덺<��]p���7�a@��0�:7�js�'p��yC�F I	|�<��'$!�[]�V׸8sxF �n�e��ö}<4d��h+[�0(i�+YU��֕��r��c)���W���p�����:��*�Rٻ}Q��z&k�s�.� ��s�G���/w��;u�pZ Y���-���/�x{݅�a���< (O(t�Ǡ����8����*T�@YXO�,�$L뵃�`g�����z`wF���A΀$ xU9�cM����bf�\L������=���
7y��恐�`kL˞穭�A��´'ٙ+��v�-�x�Y�:(��W'����RV]\u��JĹM�-��ca��� �/p�e�{c���_������6m��q��@�v�n��n��4���*Y�Sl5�`WB�D�ԝ�S�''���ɨԃ�a]3 ]�<��8� f�Y]W�F��\^�O :,N`����\�M��6�4ND�` ��I�+I���F^G����- 	���JS:@��[������k3U�M���X��_�p�P=�U �~�Ap��x׎�e-vp�7\�}��<���vL�k۸��?��l��&�_����C����A 	hm�*�sÑ�0���Mb��܁��u�aKB�,����OQ�l�;�s�rG�2_��%�[�����[䣫J��gI!{��W������O��5���kG&E�D(�E�r���	U�"j���t��V;���L�"��qBiuZ�8-�dL�	Z>3��$z/p�����Y���`>�Y�?n�?��c��O��� !7Ŏ�'̩��.��J<.�hJn�Zâ����J�19.�2M�q5����[
�!!G왌�U2��2-��Ą�� @'���
?V>��1�����'�so��2zr�ѸK�F1;s.���b;㮍���;2^ò;�^ʷ�Ǘl�N�9��dϲ�T���٧�ښv/�&�%>�p\�/��bо�.��-e���y�)<�&�n����/��vŠLV,�i���� ��V��;�'+�
���=ٙ�g���D�#p���6���޴�i{�ֹ�sQ�������9�l����ԛ��l�yp��Bw"���V7g�n}��n���8�r�ߎz)�'�%PyJȥ�
<_ڠt�>�f�\"ϭr:L��l%���*��9��r���P���(
�Z�3y�N�C׼zb	����$y�R0��n�L'<]���O��E������B�,�K�|�T�G��㣳���F�x�9���d?uj/0Rz�i@�}nY-ϥ�e��x�'�H˔��	�c�ȟ�Wi�u����M�L����ʡ��_��'��ك�&�vd�P/�a|}�@�1w�2����d�����7�}�x�Ml�Yc�o�.te�[��W�vE�C�8[}�y��sIH#�:v�k7���fg��KpE�;�ǞUJY����y�:P�q���ͷ�w��v�80`�w��/���$�Ӈ�/�Hw\�m���M���Ӷ�#���Gz��%�o�������#���)|��7v��������ԍ�|�������������#����*��6�?%�i_������}O�W6�K�_����ȶ�?��K:x�9x�9x�y�h�+���#�����Kڗ��*q��vT,�u�1�e�cJ��ڪ"����V��D�*iEɘ��'	�}f�,��j�Wa���m���k/)`�m��|��V縮Mm8�+�4}�W����&.t�i>Rhja^���SM�"zAwJ|�D;|�1����JdM���J��i-V���FG.�fD^6��~�tR�4�'�ji��Ӊj������1�s�������_~z�������˗�0��yH��>��6��x�p����*��q�9��}�}��K���=��|:�������u�GE����t�����{
��� ����忽�[�?�/����&. N����� ��]�S������Ւ�Џ�g���Ҿ��U���c�ښE��=�⽷j�|�x�>N*"(�yO��(��Ӥ�=�:�t��t����LҊ.�^{���${��$��T8��ꄣ:��#�?$��`��?*�/����P�n���3w���!�����B�����$�x���n������t������a�:�/�B���,k��)}��tn�����~ޞÌ�������'���Ϣh?�̪`��}{�/k���"	v*)�j�7�R�^�ͬ�[4{�\��C��Y���\h����ut[��5v� [���y��]q��C��� ��_��|Y��~d���;.W�yP����w��2�"�ٓ�M�Ko�]�َ�۽O��_6��� M}56�Y��L�Hz.�o�-�P��z��Z{�]��Oc�=���OY�:��a�׵,rT̚�(����i�����m@@�=-��P�����	���m@��!%�j Q�?�"���J �O���O��To��@����� �/Ob��P�n���?6����@������������;��?�V�;g�9Ӄ8gI]��ɀuS�7����_���뿔��7]���z���`�q3��N��h<�k#�k7�h6F�L�w��e5/��7
��IZ\r)(�v��s�?��A��v{;dM�P��k]��X<����N�l�b�?��KI�
-����^��om���_8�����	�)IL��9-�+��FJm���1���IIf���m���)�8^�&-I#�z�dO5���3M�/#�#c�1��a��$��@���� �o]�C�����P�n���S�}���_	P���< �p��g��3�38#A�Gt�\�aH���r!I!N�l�P�g�8P��G��P�W�_����=O_�)4[M���4�O�R8gQhP���l�]��/������.N��8�OPu�"gGB���t�����y`��m��l)9���籚(����K�΂�3q�p�Ϛ?�@��[����?�C���������?��	����ڀ �?��?�e`�o�'
��_}����ѴT稫��vs����3�uW��n���;���K���(����x�L8߼�lW��nۧ���v��٣�U��2O����e]H������M�y8[���t�	<꿷��?	�oM@��������7 ��/������_���_�������X��w��(
�_xM�y�U�����ALڲ�G�̈́�BM���.���%��g/����0Ǯjk�3g `OO�� ؟���3 �R5l���R|�T��! �� Z�yJ]]l6z����tK�𕷟c�F�)��B뵶K�V�m��FlG=N����1f���|.�ެ�R0��2���=끾�_^�-����ʷ3 ,�%�t��R��������蓾�i�� 2ۧ��<Q��H*7X��9�Sv?7iW�9~�@���!5��VZ{�x|�I�&�?p�@(�%k�H���1k5�ٱ[�Rc:�;R�L���b);��Ft�/�=1���Ќ��\d�ׇMjt��ag��">K&�_VNW��E�P��@�Ѡ������C&<�E����~?���������'�������?d�!����G��o�@�����������7������P��#?`?��qn��2�C�|�gYZ�8�g�����4�"�/D4>�G���a@��4��C�����_�W����t��c���D����0w#�dM�N-&�2�k�`����b�%�4ҭ����ß��n(��%�b?�㤺����e��K�%O���c�p]R���@{-g�ǩM��
������*����-��W	�;Tq�����	�@���;���*B5���6	d��������$��?�����x{��FU����S�U����[�7������vd6.��Ծ�.I��ں���Z����VIs������9�gf�o�l�g��bl��̈�;Ւ��:��>��Y����l;�(�8s�L��9�������V���󩯋z˟�I���yY���i�1Y�V/��З�#��nc�^���~���Xy�8���{���4I���ު�7�lcG����{\n�FBv�������X4TW�,��u��d5��4�y����\l��hLdo�n1N�k���l�1��Y�J��W�����MFFg���E��43ݡ��Xve@A�]���[��p�;����s�?��$(��	��?����G����U����o����o�����8�wX�` 	��?��C����_*������$�������_����_������`��W>���o����	x�*��{���J���8~_�S��U�*�<������_?����u�f��p����_;��?@�W��!j�?����<8��?*Z��U�*�����*�?@��?��G8~
H�?�����������͐����H�?s7��_�X�(����h���� ��� ����W���p�����H�?��kZ��U���A��� � �� ����������J���˓������[�!��ϟ���?��^	����(��0�_`���a��_]������G����Ut��>��@����
�O}�Y���J�OW1��s<�x
���C:�C�&��"���xH�x�<������4��/��O����b	��k���P]+�������ow���O�����XV��Z��Iz�4�d���G�ML"�=^�O���P���q1MY����[�9�wU�|�k�#z#��F�=Z�k�\��:b�Q�l'��o�4=:}2"�Pl*���S:m"�X������{Qu����?�և����5t}k
������?����\���ߌO����+�AH̹q�;E���3����#����a������p3u����hu����,�t����B�%�b�'3����љ8��]ӝ�`?l��ivn����P}�̚Q�S�vTv��`�2&�o����������C��p�;����0��_���`���`�����?�� ���e�����x����O����O�#J�{vkO�|y��*s�����{�v7i�H�䵉,X=ց�[2�����W�6�i%�X��L� �;�͔`7N�N>��~"ڽx��Ü��0֗�R,˃��S�i^�^�ftI��o�F;-�{m7���ӷ���K'���-�%�t�,�XmI�����e�>鋝f"�}IJ��aߍ�rk<���>e�s�v��~Y Ւ�wܝ��I�I@%�L;���ۜ{gon�B��[y��H�p2�����S��ū��1D2��΄iD��jη�������?���~���|�7���ei�ao� �Q8���G\���~���������_	P���A�'�W����?%��������8��8	��J���8q������@5����	��*�����{����,�U�5��tdY�]���ice�I�B�z��Ow�"P~u�GK�����Y��g�M����^�{�F�x�������b�a�<?�P�/=���u�R�b]o��͹���`�-;�#���U�����$��:���,w�r��ٵ=P����Uثm|��r.��$�,[�I�l8�E���MF:��]�n:Z��u�O	Ɨ�}J�����-Z���{r���K;w}���O��cQ/������)��4���L��D�%��M�Ր�ݶ,������f�bˈ<��[���q�s�c�#*�*&��%6/1�e��|$��h,z�8��x�`��d""��K�����>O�	
Cb���=�����y�X��ʺ�����������+B5��<`	��9OФ/̩��O�l(�q������)a�S\��L�G�@�3���(�P����_���U�_9����\�x��6H�u�c�7�OG�`�/�Q��F��ȅ'E_����ʟ�
��rS+0��V|���f������U �GpԽ���T���aTq�_�����?�_%x���7�����i��w�DH㋩r�	;��w���T���E��@�Z0O���`��������a?��ݬ?���Đ�������~��|?�JvǒJ��Ꭼ�vJ6�ZK�=>�3aC����N#��/�!+ʛ 
�]�-��|\N6�n�hYwt�����~/�������$�،ѝ���q���D->_�i�NcQ��JQ��~b2�.������lF�D�^M��%ƙ�i囕[��~��F�_gxn)s����т^G�퍵e�n��������-V������h��+A��gC:�X�'pjΓ����GE� `|��}����f<��>I0�g^����@Tq����X�?*����Zv����h1~�<p���N���8��|�+E?TE���a'�����l��콲���⣿����w�E��WP�W�w��p�U��������?����_��b����v2����������	�%x��#�����?Z�nS�܍e{=��������?d�<��5$�%�������R����l��K���A$��Q)C�^̥z1���\����甯���޹���-y�w�
6wtuW��<��^��c���X�"���0`c{4���vw҉=�N&�0q}�(n�1��T�SUg��/3WطN]��\aOKW.����5�aue�׻��^��:'�xZ���W;���םF��*�`��*]��[�QX���0�Ƨ��`b�aų����)�ӷ]�#x%WZ��YK���m�Ք�%�,�)$������RS��e�g)J�D�g�94Y��vթ�{gm�
�x��;��4��[u�H�ּ*��O�������Ա����j��`8d���5L,�j�ѷ��\;�z��ʀ))5�^I5W�y�6�c���Zi$E����%��3�o������n���?��E�o���������˃���O��R�!4������䋐��	�	��	�0��ߏ���r�a �����_���ё��C!�������[��0��	P��A�7���������e�/�W	�Y��_��3$��ِ���C�ό�F�����G�	�������F�/��f*�?���v ������U����(��B�����37��@�� '�u!���]����� �����_ra��7�!�#P��������˅���?@�GF�A�!#�����?���2�?@��� �`�쿬�?�������˅���?2r��P�����?����� ������h��o����L@i�E���������\�?s���eB>���Q�����������K.�?���D���V�1������߷���/RW�?�������)�"�?gu���<77�2m1����b��,�dQ&Ù�m��t�Xd��ɱ�u����A��ܵ����������Q��uy���+5�����T��V�7�r��"Iϯ�&*d����]��N�;u�d�8�)V[�ζ�:͗�
��`��{�ݔ=�<]=hzv�E�Gm:,�q;,E���m����d�5��\O����5��nǩ�1Gy�2�/��S��Zo�+�h�G��P7x��C��?с����0��������<�?�����_��1uQ���������u�I+�j�C���Hb	_/$e�
�I�q�Ӷ����r�L�/�_]���V{��f���mu��&�K;,�h�_K��vǷjE�����\��*�<��j�]jcO��+%t���BO����/��/"P����h�?c����E��!� �� ����C4�6 Bra��ܕ��P`�e���=���_���a5�_�م���b�w~:��:�����S��Uq�P��?����m���6�T����]�$�vw�Z���h�6�I�/��a\��ɸ��#Ҟc���S�̗'�N��{�����AQ��J)��+חFE�6�b�]���?e�+��ɖ����䄢#WŮYyJSH����ο{Ex��$5I���|�)k�u�h�6��W6���|U��J8�Z�6�(������.�:�.���T�B�8��ô��VK�B%��^�u��Ґ!�#�Pv�KڦB���Az����{M�?���O�������S����4�Gވ� ��Ȃ\�?#���ς�������'����������,� ��s��s@�A���?u#��2���Zu[�#���������񿙐'��*�ٓ��m��s���x��#�����K.�?���/������ ���}���X���X�	������_
�?2���s���1�C�K�� rŎ8>�d�7��y������0�j�9�#a�r?Ήط����r?�_���܏s�����IS����_�~_�7����v�nܯu�U��;N�B%�X�e+sf������ސ�1��ٙ����	�ư�(P��0c��d�O�MUs\5�F�_�[�~_�~�y��!�6�(�+m� �
<늿T�p�L�}1���$Ա�y��;����D1��b�ٌ(r`Mxf5iK��!Y��F��01�zzԦ�^dԭ��=k����l�5��RcSm��DxT���~ra���?2���G�����m��B�a�y����0
�)���o���`�?������_P������"��G�w	���m��B�Y�9��{� ��&�?��#�K��r��U�Qێ�zm�SJ#�����O5�_u����(���Dkonzks3:��)�Y ��Ǉ��>�V��c�t��N/�%������6��~Sէ-z�4�bߊL��~���i�[4��A��C��%���7�e�l��?���I % ;'�Y@/���:����(ˁХTa_���p��ͷ�(��jT�{�=Y6��*�Qy�R�C�[��
{]�,Mb�D�ep\��'T���w㿙\�ԍ�_��W& ��>,��%������˃������Y��g�o�E޶9���%ݚI��Y���bi���R�b)�&u��mִ���%��s���Gݿ?3y��[�B�6|��?��ﻌW2�Y����B�TK���^?��zm�^U�i\.���y,�	M��N�B]���p��kLY�j��������ƝJ.]X��-v�|��k�,�ȶ
\� ;�O`�Ϸ�����i�^
u�9y����CG.����\��L�@�Mq��A���C������n=^,�FG�DbNbb�������F\m��)��w�/�ח��v8��AT�zc�1kBJ�F}�bA|��#vBG�Q�����N�b#4+n+��x<�#:k?
��dٓ�������|��W�_,�@����S�����/��B�A��A������r�l@4���c�"�����7>�����k,̀{��M�r9��[һ
�����9 ����� �e!��9 �������[]�$�
��D��q��s��Z�r�Jͧ2�"��rV��#��'�`�)��Byh�X�Q7�H3jTiVhm��z)��ӧfv��D]Hj�g;O|�V��LE�;�	�yL0R��*&M��|�VEItz��3�����CC+ɪd�m��8���*"�`���=QJ��W�M��M��鲟�S��a�򣽈}V8P��X4������
S�G��[xKN���q�̎-{`������H�9XEf9n,�=5����-�zm�t��)ӣ��2��3�Z�~���]������/�?ɤ��'�O3Â�g��;w,O�Y�[��s���㧝��Qߤ�z�0ƫ��S��RUy��_�+�e��p>�C����p���i_L%��ȍ��X\��
�p=8���yßQZ�g�_%�Vz��o�j^�L�X��Z�_6?�����������է-�������}���<������p=�У���n��n�a�V��� t������ѽy�EV�?X��g�P7�xa��.�tϹZf�G���~}�˿ps���K7x��J_�&
���~{ؓ��%���w�����O<H������G~K����1��SQ8?ϗ7��z'��}��5>��[?�����:=m���1�µ5w��<x��OOH���zzx߾4_�'�T�繞��S�
?��q7�v����Bo�~�6��p������M�ncX��`����_~����X������gw����,{�kN��2���B��굣������y9ă������'Y2�����܄���c�/�~K��'����G������x��*�[Lj���Y�o�;R�UU�����$�I��,|��?������0���>�_�sWv����ǻ�g                           �����eHa � 