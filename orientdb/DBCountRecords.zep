/**
 * OrientDB DBCountRecords class
 * Asks for the number of records in a database in the OrientDB Server instance.
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
 * DBCountRecords() Operation for OrientDB
 *
 * @author Hugo Hiram <hugo@hugohiram.com>
 * @package OrientDB
 * @subpackage Operation
 */
class DBCountRecords extends OperationAbstract
{
	/**
	 * Orientdb\DBCountRecords constructor
	 *
	 * @param object parent object of caller class
	 */
	public function __construct(parent)
	{
		//echo __CLASS__;
		let this->parent = parent;
		let this->socket = parent->socket;

		let this->operation = OperationAbstract::REQUEST_DB_COUNTRECORDS;
	}

	/**
	 * Main method to run the operation
	 * 
	 * @return long
	 */
	public function run() -> long
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
	 * @return long
	 */
	protected function parseResponse() -> long
	{
		var status, count;

		let status = this->readByte(this->socket);
		let this->session = this->readInt(this->socket);
		this->parent->setSession(this->session);
		if (status == (chr(OperationAbstract::STATUS_SUCCESS))) {
			let count = this->readLong(this->socket);
			return count;
		}
		else {
			this->handleException();
		}

		return 0;
	}
}