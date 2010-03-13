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
    public class MixiVoice
    {
        private var _memberID:uint;
        private var _nickname:String;
        private var _postTime:Date;
        private var _isOfficial:Boolean;
        private var _body:String;

        public function MixiVoice(memberID:uint, nickname:String,
            postTime:Date, body:String, isOfficial:Boolean=false)
        {
            _memberID   = memberID;
            _nickname   = nickname;
            _postTime   = postTime;
            _body       = body;
            _isOfficial = isOfficial;
        }

        public function get memberID():uint
        {
            return _memberID;
        }

        public function get nickname():String
        {
            return _nickname;
        }

        public function get body():String
        {
            return _body;
        }

        public function get postTime():Date
        {
            return _postTime;
        }

        public function get isOfficial():Boolean
        {
            return _isOfficial;
        }

        public function toString():String
        {
            return "["
            +  "memberID:"    + String(_memberID)
            + ",nickname:"    + _nickname
            + ",postTime:"    + String(_postTime)
            + ",body:"        + _body
            + ",isOfficial:"  + String(_isOfficial)
            + "]";
        }
    }
}

