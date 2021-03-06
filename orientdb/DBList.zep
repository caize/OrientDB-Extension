/**
 * OrientDB DBList class
 *
 * @author Hugo Hiram <hugo@hugohiram.com>
 * @copyright Hugo Hiram 2014
 * @license MIT License (MIT) https://github.com/hugohiram/OrientDB-Extension/blob/master/LICENSE
 * @link https://github.com/hugohiram/OrientDB-Extension
 * @package OrientDB
 */

namespace Orientdb;

use Orientdb\Exception\OrientdbException;

/**
 * DBList() Operation for OrientDB
 *
 * @author Hugo Hiram <hugo@hugohiram.com>
 * @package OrientDB
 * @subpackage Operation
 */
class DBList extends OperationAbstract
{

	/**
	 * Orientdb\DBList constructor
	 *
	 * @param object parent object of caller class
	 */
	public function __construct(parent)
	{
		//echo __CLASS__;
		let this->parent = parent;
		let this->socket = parent->socket;

		let this->operation = OperationAbstract::REQUEST_DB_LIST;

		if (this->parent->debug == true) {
			syslog(LOG_DEBUG, __METHOD__);
		}
	}

	/**
	 * Main method to run the operation
	 * 
	 * @return string
	 */
	public function run() -> string
	{
		this->prepare();
		this->execute();
		let this->response = this->parseResponse();

		return this->response;
	}

	/**
	 * Prepare the parameters
	 * 
	 * @return void
	 */
	protected function prepare() -> void
	{
		this->resetRequest();
		let this->session = this->parent->getSession();
		this->addByte(chr(this->operation));
		this->addInt(this->session);
	}

	/**
	 * Parse the response from the socket
	 * 
	 * @return array
	 */
	protected function parseResponse() -> array
	{
		var status, content, databases;
		var contentJson, posl, posr;

		let databases = [];
		let status = this->readByte(this->socket);
		let this->session = this->readInt(this->socket);
		this->parent->setSession(this->session);

		if (status == (chr(OperationAbstract::STATUS_SUCCESS))) {
			if (this->parent->debug == true) {
				syslog(LOG_DEBUG, __METHOD__ . " status: ok");
			}

			let content = this->readString(this->socket);
			if (this->parent->debug == true) {
				syslog(LOG_DEBUG, __METHOD__ . " content: " . content);
			}

			let posl = strpos(content, "{");
			let posr = strripos(content, "}");

			if (this->parent->debug == true) {
				syslog(LOG_DEBUG, __METHOD__ . " content posl: " . posl);
				syslog(LOG_DEBUG, __METHOD__ . " content posr: " . posr);
			}

			let contentJson = substr(content, posl, posr);

			if (this->parent->debug == true) {
				syslog(LOG_DEBUG, __METHOD__ . " content JSON: " . contentJson);
			}

			if !empty content {
				let databases = json_decode(contentJson);
			}
		}
		else {
			if (status == (chr(OperationAbstract::STATUS_ERROR))) {
				this->handleException();
			}
		}

		return databases;
	}
}