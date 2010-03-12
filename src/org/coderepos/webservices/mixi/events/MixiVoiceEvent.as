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

package org.coderepos.webservices.mixi.events
{
    import flash.events.Event;
    import org.coderepos.webservices.mixi.voice.MixiVoice;

    public class MixiVoiceEvent extends Event
    {
        public static const RETRIEVED:String = "voiceRetrieved";
        public static const POSTED:String    = "voicePosted";
        public static const COMPLETE:String  = "voiceComplete";

        private var _voice:MixiVoice;

        public function MixiVoiceEvent(type:String, voice:MixiVoice=null,
            bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            _voice = voice;
        }

        public function get voice():MixiVoice
        {
            return _voice;
        }
    }
}

