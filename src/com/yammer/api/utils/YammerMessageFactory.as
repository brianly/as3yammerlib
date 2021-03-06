/**
 * @author Michael Ritchie
 * @email michael.ritchie@gmail.com
 * @twitter thanksmister
 * @version 11.03.09
 */
package com.yammer.api.utils
{
	import com.yammer.api.vo.YammerGroup;
	import com.yammer.api.vo.YammerLikedByNames;
	import com.yammer.api.vo.YammerMessage;
	import com.yammer.api.vo.YammerMessageList;
	import com.yammer.api.vo.YammerTag;
	import com.yammer.api.vo.YammerThread;
	import com.yammer.api.constants.YammerTypes;
	import com.yammer.api.vo.YammerUser;
	
	import flash.utils.Dictionary;
	
	/**
	 * Factory class to crate <code>YammerMessage</code> objects.
	 * */
	public class YammerMessageFactory	
	{
		public function YammerMessageFactory():void
		{
			throw Error("The YammerMessageFactory class cannot be instantiated.");
		}
		
		public static function createMessages(list:Array, messageList:YammerMessageList = null):Array
		{
			var messages:Array = new Array();
			
			for each (var msg:Object in list){
				var message:YammerMessage = createMessage(msg, messageList);
				messages.push(message);
			}

			list = null;
			
			return messages;
		}
		
		public static function createMessage(obj:Object, messageList:YammerMessageList = null):YammerMessage 
		{	
			var message:YammerMessage = new YammerMessage();
	
			try{
				if(obj.id) message.id = obj.id; 
				
				if(obj.message_type) message.type = obj.message_type;
				if(obj.web_url) message.web_url = obj.web_url;
				if(obj.url) message.url = obj.url;
	
				if(obj.sender_type) message.sender_type = obj.sender_type;
				if(obj.sender_id) message.sender_id = obj.sender_id;
				
				/*
				if(message.sender_type == YammerTypes.GUIDE_TYPE) {
					message.sender = references[YammerTypes.GUIDE_TYPE][message.sender_id];
				} else if (message.sender_type == YammerTypes.BOT_TYPE){
					message.sender = references[YammerTypes.BOT_TYPE][message.sender_id];
					// We ignore bots because the current API does not list them in the "followers" meta data and we mark them as followed by default
					if(message.sender) message.sender.is_followed = true; 
				} else if (message.sender_type == YammerTypes.USER_TYPE){
					message.sender = references[YammerTypes.USER_TYPE][message.sender_id];
				}
				*/
				
				// TODO  identify from list of followers if sender is being followed
				
				/*
				if(message.sender){
					for each (var followid:String in followed_user_ids) {
						if(message.sender_id == followid) {
							message.sender.is_followed = true;
							break;
						} 
					}
				}
				*/
				
				// liked by counts, permalinks, and full names appeneded to each message
				if(obj.liked_by) message.liked_by_count = Number(obj.liked_by.count);
				if(obj.liked_by) message.liked_by_names = getLikedNames(obj.liked_by.names as Array);
				
				//  identify message as liked message from the meta information on message list
				for each (var likeid:String in messageList.liked_message_ids) {
					if(message.id == likeid) message.is_liked = true;
				}
			
				// identify message as favorite message from the meta information on message list
				for each (var favoriteid:String in messageList.favorite_message_ids) {
					if(message.id == favoriteid) message.is_favorite = true;
				}
				
				// group message was posted in
				if(obj.group_id) message.group_id = obj.group_id;
				
				/*
				if(obj.group_id){
					message.group_id = obj.group_id;
					if(message.group_id) {
				 		message.group = references[YammerTypes.GROUP_TYPE][message.group_id];
					}
				}
				*/
				
				if(obj.thread_id) message.thread_id = obj.thread_id;
				if(obj.replied_to_id) message.reply_to_id = obj.replied_to_id;
				
				/*
				if(obj.replied_to_id) {
					message.reply_to_id = obj.replied_to_id;
					if(references[YammerTypes.MESSAGE_TYPE][message.reply_to_id]){
						try{
							message.recipient_message = references[YammerTypes.MESSAGE_TYPE][message.reply_to_id];
							message.recipient = references[YammerTypes.USER_TYPE][message.recipient_message.sender_id];
							if(!message.recipient) message.recipient = references[YammerTypes.BOT_TYPE][message.recipient_message.sender_id];
						} catch (e:Error){ trace(">>Error finding message: " + e.message);}	
					}
				} 
				*/
				
				if(obj.direct_to_id) message.direct_to_id = obj.direct_to_id;
					
				/*
				if(obj.direct_to_id) {
					message.direct_to_id = obj.direct_to_id;
					if (message.direct_to_id) { 
						message.recipient = references[YammerTypes.USER_TYPE][message.direct_to_id];
					}
				} 
				*/
				
				if(obj.client_type) message.client_type = obj.client_type;
				if(obj.client_url) message.client_url = obj.client_url;
	
				if(obj.created_at) message.created_at = new Date(String(obj.created_at)); 
	
				if(obj.body){
					message.body_plain = obj.body.plain; 
					message.body_parsed = obj.body.parsed;
			
				}
	
				if(obj.system_message) message.system_message = (obj.system_message == 'true') ? true : false;
				
				// TODO move this to cach manager?   attachments usually not duplicated on other objects
				message.attachments = getAttachments(obj.attachments as Array);
	
				obj = null;
				
			} catch (error:Error){
				trace("Exception parsing message: " + "\nError: " + error.message);
				
			}
			return message;
		}
		
		public static function getLikedNames(list:Array):Array
		{
			var arr:Array = new Array();
			for each (var obj:Object in list) {
				var like:YammerLikedByNames = new YammerLikedByNames();
					like.full_name = obj.full_name;
					like.permalink = obj.permalink;
				arr.push(like);
			}
			list = null;
			return arr;
		}
		
		private static function getAttachments(list:Array):Array 
		{
			var arr:Array = new Array();
			for each (var attachment:Object in list) {
				arr.push(YammerFactory.attachment(attachment));
			}
			list = null;
			return arr;
		}
	}
}