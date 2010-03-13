/*
Copyright (c) Lyo Kato (lyo.kato _at_ gmail.com)

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package org.coderepos.webservices.mixi.voice
{
    import org.coderepos.webservices.mixi.exceptions.MixiProtocolError;

    public class MixiVoiceBuffer
    {
        private var _memberID:uint;
        private var _postTime:Date;
        private var _nickname:String;
        private var _body:String;
        private var _isOfficial:Boolean;
        private var _hasEnough:Boolean;
        private var _capturingType:String;

        public function MixiVoiceBuffer()
        {
            _memberID      = 0;
            _isOfficial    = false;
            _hasEnough     = false;
            _capturingType = null;
        }

        public function capture(s:String):void
        {
            if (_capturingType == null)
                return;

            switch (_capturingType) {
                case MixiVoiceElementClassType.MEMBER_ID:
                    _memberID = uint(s);
                    break;
                case MixiVoiceElementClassType.POST_TIME:
                    _postTime = parseDateString(s);
                    break;
                case MixiVoiceElementClassType.NICKNAME:
                    _nickname = s;
                    break;
                case MixiVoiceElementClassType.BODY:
                    _body = s;
                    break;
                case MixiVoiceElementClassType.OFFICIAL_POST:
                    _isOfficial = (s != '0');
                    _hasEnough = true;
                    break;
            }
        }

        private function parseDateString(s:String):Date
        {
            var matched:Array = s.match(/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/);
            if (matched == null)
                throw new MixiProtocolError("Invalid voice - postTime format: " + s);

            var year:Number    = Number(matched[1]);
            var month:Number   = Number(matched[2]) - 1;
            var day:Number     = Number(matched[3]);
            var hours:Number   = Number(matched[4]);
            var minuts:Number  = Number(matched[5]);
            var seconds:Number = Number(matched[6]);

            return new Date(year, month, day, hours, minuts, seconds);
        }

        public function get hasEnough():Boolean
        {
            return _hasEnough;
        }

        public function get isCapturing():Boolean
        {
            return (_capturingType != null);
        }

        public function startCapturing(type:String):void
        {
            _capturingType = type;
        }

        public function finishCapturing():void
        {
            _capturingType = null;
        }

        public function buildVoice():MixiVoice
        {
            return new MixiVoice(_memberID, _nickname, _postTime, _body, _isOfficial);
        }
    }
}

