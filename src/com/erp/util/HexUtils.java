package com.erp.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/*
 * #%L
 * ch-commons-util
 * %%
 * Copyright (C) 2012 Cloudhopper by Twitter
 * %%
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * #L%
 */

/*
 * modified by pangj@eastcompeace.com
 * 
 */

/**
 * Utility class for encoding or decoding objects to a hexidecimal format.
 * 
 * @author joelauer (twitter: @jjlauer or <a href="http://twitter.com/jjlauer" target=window>http://twitter.com/jjlauer</a>)
 */
public class HexUtils {

    public static char[] HEX_TABLE = {
        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'
    };

    /**
     * Creates a String from a byte array with each byte in a "Big Endian"
     * hexidecimal format. For example, a byte 0x34 will return a
     * String "34".  A byte array of { 0x34, 035 } would return "3435".
     * @param buffer The StringBuilder the byte array in hexidecimal format
     *      will be appended to.  If the buffer is null, this method will throw
     *      a NullPointerException.
     * @param bytes The byte array that will be converted to a hexidecimal String.
     *      If the byte array is null, this method will append nothing (a noop)
     */
    public static String toHexString(byte[] bytes) {
        if (bytes == null) {
            return "";
        }
        return toHexString(bytes, 0, bytes.length);
    }
    
    public static String toHexString(String prefix, byte[] bytes) {
    	if (prefix == null)
    		prefix = "";
    	
    	 if (bytes == null)
             return prefix;
    	 
        return toHexString(prefix, bytes, 0, bytes.length);
    }

    /**
     * Creates a String from a byte array with each byte in a "Big Endian"
     * hexidecimal format. For example, a byte 0x34 will return a
     * String "34".  A byte array of { 0x34, 035 } would return "3435".
     * @param buffer The StringBuilder the byte array in hexidecimal format
     *      will be appended to.  If the buffer is null, this method will throw
     *      a NullPointerException.
     * @param bytes The byte array that will be converted to a hexidecimal String.
     *      If the byte array is null, this method will append nothing (a noop)
     * @param offset The offset in the byte array to start from. If the offset
     *      or length combination is invalid, this method will throw an IllegalArgumentException.
     * @param length The length (from the offset) to conver the bytes. If the offset
     *      or length combination is invalid, this method will throw an IllegalArgumentException.
     */
    public static String toHexString(byte[] bytes, int offset, int length) {
        if (bytes == null) {
            return "";
        }
        assertOffsetLengthValid(offset, length, bytes.length);
        // each byte is 2 chars in string
        StringBuilder buffer = new StringBuilder(length * 2);
        appendHexString(buffer, bytes, offset, length);
        return buffer.toString();
    }
    
    /**
     * @param prefix
     * @param bytes
     * @param offset
     * @param length
     * @return
     */
    public static String toHexString(String prefix, byte[] bytes, int offset, int length) {
    	
    	if (prefix == null)
    		prefix = "";
    	
    	 if (bytes == null)
             return prefix;
    	
    	assertOffsetLengthValid(offset, length, bytes.length);
    	
    	// each byte is 2 chars in string
        StringBuilder buffer = new StringBuilder(prefix.length() + length * 2);
        buffer.append(prefix);
        appendHexString(buffer, bytes, offset, length);
        return buffer.toString(); 
    }

    /**
     * Appends a byte array to a StringBuilder with each byte in a "Big Endian"
     * hexidecimal format. For example, a byte 0x34 will be appended as a
     * String in format "34".  A byte array of { 0x34, 035 } would append "3435".
     * @param buffer The StringBuilder the byte array in hexidecimal format
     *      will be appended to.  If the buffer is null, this method will throw
     *      a NullPointerException.
     * @param bytes The byte array that will be converted to a hexidecimal String.
     *      If the byte array is null, this method will append nothing (a noop)
     */
    public static void appendHexString(StringBuilder buffer, byte[] bytes) {
        assertNotNull(buffer);
        if (bytes == null) {
            return;     // do nothing (a noop)
        }
        appendHexString(buffer, bytes, 0, bytes.length);
    }

    /**
     * Appends a byte array to a StringBuilder with each byte in a "Big Endian"
     * hexidecimal format. For example, a byte 0x34 will be appended as a
     * String in format "34".  A byte array of { 0x34, 035 } would append "3435".
     * @param buffer The StringBuilder the byte array in hexidecimal format
     *      will be appended to.  If the buffer is null, this method will throw
     *      a NullPointerException.
     * @param bytes The byte array that will be converted to a hexidecimal String.
     *      If the byte array is null, this method will append nothing (a noop)
     * @param offset The offset in the byte array to start from. If the offset
     *      or length combination is invalid, this method will throw an IllegalArgumentException.
     * @param length The length (from the offset) to conver the bytes. If the offset
     *      or length combination is invalid, this method will throw an IllegalArgumentException.
     */
    static public void appendHexString(StringBuilder buffer, byte[] bytes, int offset, int length) {
        assertNotNull(buffer);
        if (bytes == null) {
            return;     // do nothing (a noop)
        }
        assertOffsetLengthValid(offset, length, bytes.length);
        int end = offset + length;
        for (int i = offset; i < end; i++) {
            int nibble1 = (bytes[i] & 0xF0) >>> 4;
            int nibble0 = (bytes[i] & 0x0F);
            buffer.append(HEX_TABLE[nibble1]);
            buffer.append(HEX_TABLE[nibble0]);
        }
    }

    /**
     * Creates a 2 character hex String from a byte with the byte in a "Big Endian"
     * hexidecimal format. For example, a byte 0x34 will be returned as a
     * String in format "34".  A byte of value 0 will be returned as "00".
     * @param value The byte value that will be converted to a hexidecimal String.
     */
    static public String toHexString(byte value) {
        StringBuilder buffer = new StringBuilder(2);
        appendHexString(buffer, value);
        return buffer.toString();
    }

    /**
     * Appends 2 characters to a StringBuilder with the byte in a "Big Endian"
     * hexidecimal format. For example, a byte 0x34 will be appended as a
     * String in format "34".  A byte of value 0 will be appended as "00".
     * @param buffer The StringBuilder the byte value in hexidecimal format
     *      will be appended to.  If the buffer is null, this method will throw
     *      a NullPointerException.
     * @param value The byte value that will be converted to a hexidecimal String.
     */
    static public void appendHexString(StringBuilder buffer, byte value) {
        assertNotNull(buffer);
        int nibble = (value & 0xF0) >>> 4;
        buffer.append(HEX_TABLE[nibble]);
        nibble = (value & 0x0F);
        buffer.append(HEX_TABLE[nibble]);
    }

    /**
     * Creates a 4 character hex String from a short with the short in a "Big Endian"
     * hexidecimal format. For example, a short 0x1234 will be returned as a
     * String in format "1234". A short of value 0 will be returned as "0000".
     * @param value The short value that will be converted to a hexidecimal String.
     */
    static public String toHexString(short value) {
        StringBuilder buffer = new StringBuilder(4);
        appendHexString(buffer, value);
        return buffer.toString();
    }

    /**
     * Appends 4 characters to a StringBuilder with the short in a "Big Endian"
     * hexidecimal format. For example, a short 0x1234 will be appended as a
     * String in format "1234". A short of value 0 will be appended as "0000".
     * @param buffer The StringBuilder the short value in hexidecimal format
     *      will be appended to.  If the buffer is null, this method will throw
     *      a NullPointerException.
     * @param value The short value that will be converted to a hexidecimal String.
     */
    static public void appendHexString(StringBuilder buffer, short value) {
        assertNotNull(buffer);
        int nibble = (value & 0xF000) >>> 12;
        buffer.append(HEX_TABLE[nibble]);
        nibble = (value & 0x0F00) >>> 8;
        buffer.append(HEX_TABLE[nibble]);
        nibble = (value & 0x00F0) >>> 4;
        buffer.append(HEX_TABLE[nibble]);
        nibble = (value & 0x000F);
        buffer.append(HEX_TABLE[nibble]);
    }

    /**
     * Creates an 8 character hex String from an int twith the int in a "Big Endian"
     * hexidecimal format. For example, an int 0xFFAA1234 will be returned as a
     * String in format "FFAA1234". A int of value 0 will be returned as "00000000".
     * @param value The int value that will be converted to a hexidecimal String.
     */
    static public String toHexString(int value) {
        StringBuilder buffer = new StringBuilder(8);
        appendHexString(buffer, value);
        return buffer.toString();
    }

    /**
     * Appends 8 characters to a StringBuilder with the int in a "Big Endian"
     * hexidecimal format. For example, a int 0xFFAA1234 will be appended as a
     * String in format "FFAA1234". A int of value 0 will be appended as "00000000".
     * @param buffer The StringBuilder the int value in hexidecimal format
     *      will be appended to.  If the buffer is null, this method will throw
     *      a NullPointerException.
     * @param value The int value that will be converted to a hexidecimal String.
     */
    static public void appendHexString(StringBuilder buffer, int value) {
        assertNotNull(buffer);
        int nibble = (value & 0xF0000000) >>> 28;
        buffer.append(HEX_TABLE[nibble]);
        nibble = (value & 0x0F000000) >>> 24;
        buffer.append(HEX_TABLE[nibble]);
        nibble = (value & 0x00F00000) >>> 20;
        buffer.append(HEX_TABLE[nibble]);
        nibble = (value & 0x000F0000) >>> 16;
        buffer.append(HEX_TABLE[nibble]);
        nibble = (value & 0x0000F000) >>> 12;
        buffer.append(HEX_TABLE[nibble]);
        nibble = (value & 0x00000F00) >>> 8;
        buffer.append(HEX_TABLE[nibble]);
        nibble = (value & 0x000000F0) >>> 4;
        buffer.append(HEX_TABLE[nibble]);
        nibble = (value & 0x0000000F);
        buffer.append(HEX_TABLE[nibble]);
    }

    /**
     * Creates a 16 character hex String from a long with the long in a "Big Endian"
     * hexidecimal format. For example, a long 0xAABBCCDDEE123456 will be returned as a
     * String in format "AABBCCDDEE123456". A long of value 0 will be returned as "0000000000000000".
     * @param value The long value that will be converted to a hexidecimal String.
     */
    static public String toHexString(long value) {
        StringBuilder buffer = new StringBuilder(16);
        appendHexString(buffer, value);
        return buffer.toString();
    }

    /**
     * Appends 16 characters to a StringBuilder with the long in a "Big Endian"
     * hexidecimal format. For example, a long 0xAABBCCDDEE123456 will be appended as a
     * String in format "AABBCCDDEE123456". A long of value 0 will be appended as "0000000000000000".
     * @param buffer The StringBuilder the long value in hexidecimal format
     *      will be appended to.  If the buffer is null, this method will throw
     *      a NullPointerException.
     * @param value The long value that will be converted to a hexidecimal String.
     */
    static public void appendHexString(StringBuilder buffer, long value) {
        appendHexString(buffer, (int)((value & 0xFFFFFFFF00000000L) >>> 32));
        appendHexString(buffer, (int)(value & 0x00000000FFFFFFFFL));
    }

    static private void assertNotNull(StringBuilder buffer) {
        if (buffer == null) {
            throw new NullPointerException("The buffer cannot be null");
        }
    }

    static private void assertOffsetLengthValid(int offset, int length, int arrayLength) {
        if (offset < 0) {
            throw new IllegalArgumentException("The array offset was negative");
        }
        if (length < 0) {
            throw new IllegalArgumentException("The array length was negative");
        }
        if (offset+length > arrayLength) {
            throw new ArrayIndexOutOfBoundsException("The array offset+length would access past end of array");
        }
    }

    /**
     * Converts a hexidecimal character such as '0' or 'A' or 'a' to its integer
     * value such as 0 or 10.  Used to decode hexidecimal Strings to integer values.
     * @param c The hexidecimal character
     * @return The integer value the character represents
     * @throws IllegalArgumentException Thrown if a character that does not
     *      represent a hexidecimal character is used.
     */
    static public int hexCharToIntValue(char c) {
    	if (c >= '0' && c <= '9')
    		return c - '0';
    	else if (c >= 'A' && c <= 'F')
    		return c - ('A' - 10);
    	else if (c >= 'a' && c <= 'f')
    		return c - ('a' - 10);
    	else
    		throw new IllegalArgumentException("The character [" + c + "] does not represent a valid hex digit");
    }

    /**
     * Creates a byte array from a CharSequence (String, StringBuilder, etc.)
     * containing only valid hexidecimal formatted characters.
     * Each grouping of 2 characters represent a byte in "Big Endian" format.
     * The hex CharSequence must be an even length of characters. For example, a String
     * of "1234" would return the byte array { 0x12, 0x34 }.
     * @param hexString The String, StringBuilder, etc. that contains the
     *      sequence of hexidecimal character values.
     * @return A new byte array representing the sequence of bytes created from
     *      the sequence of hexidecimal characters.  If the hexString is null,
     *      then this method will return null.
     */
    public static byte[] toByteArray(CharSequence hexString) throws IllegalArgumentException {
        if (hexString == null) {
            return null;
        }
        return toByteArray(hexString, 0, hexString.length());
    }

    /**
     * Creates a byte array from a CharSequence (String, StringBuilder, etc.)
     * containing only valid hexidecimal formatted characters.
     * Each grouping of 2 characters represent a byte in "Big Endian" format.
     * The hex CharSequence must be an even length of characters. For example, a String
     * of "1234" would return the byte array { 0x12, 0x34 }.
     * @param hexString The String, StringBuilder, etc. that contains the
     *      sequence of hexidecimal character values.
     * @param offset The offset within the sequence to start from.  If the offset
     *      is invalid, will cause an IllegalArgumentException.
     * @param length The length from the offset to convert. If the length
     *      is invalid, will cause an IllegalArgumentException.
     * @return A new byte array representing the sequence of bytes created from
     *      the sequence of hexidecimal characters.  If the hexString is null,
     *      then this method will return null.
     * @throws IllegalArgumentException when caught hex string exception
     */
    /*
     * modified by pangj
     * 
     */
    public static byte[] toByteArray(CharSequence hexString, int offset, int length) throws IllegalArgumentException {
    	
        if (hexString == null) {
            return null;
        }
        
        // ����ǰ׺0x
        if (length > 2) {
        	char firstChar = hexString.charAt(offset);
        	char secondChar = hexString.charAt(offset+1);
        	if (firstChar == '0' && Character.toUpperCase(secondChar) == 'X') {
        		offset += 2;
        		length -= 2;
        	}
        }
        
        byte[] bytes = new byte[length/2];
        int j = 0;
        int end = offset+length;

		int hi = -1;
		int x = -1;
		
		for (int i = offset; i < end; i++) {
			
			char ch = hexString.charAt(i);
			if (ch <= ' ' || ch == '_')	// ignored space/tab/'\r'/'\n'. '_'
				continue;
			if (ch >= '0' && ch <= '9') 
				x = ch - '0';
			else if (ch >= 'A' && ch <= 'F') 
				x = ch - ('A' - 10);
			else if (ch >= 'a' && ch <= 'f') 
				x = ch - ('a' - 10);
			else {
				ch = hexString.charAt(i);
				throw new IllegalArgumentException("bad hex string: invalid charactor '" + 
						ch + "' (" + (int)ch + ")");
			}

			if (hi == -1) {
				hi = x;
			}
			else {
				x = (hi << 4) + x;
				hi = -1;
				bytes[j++] = (byte)x;
			}
		}
		
		if (hi != -1) {
			throw new IllegalArgumentException("bad hex string: missing semi-byte, actual length is " + j + " and 1/2 bytes");
		}
		if (j == length)
			return bytes;
		else {
			byte[] temp = new byte[j];
			System.arraycopy(bytes, 0, temp, 0, j);
			return temp;
		}
    }
    
    /**
     * @param hexString
     * @param allowSpaceChars
     * @return
     */
    public static int countHexChars(CharSequence hexString, boolean allowSpaceChars) {
    	
    	 if (hexString == null)
    		 return 0;
    	 
    	 return countHexChars(hexString, 0, hexString.length(), allowSpaceChars);
    }
    
    /**
     * @param hexString
     * @param offset
     * @param length
     * @param allowSpaceChars
     * @return
     */
    public static int countHexChars(CharSequence hexString, int offset, int length, boolean allowSpaceChars) {
    	
    	if (hexString == null) {
            return 0;
        }
        
        int count = 0;
        int end = offset+length;
		
		for (int i = offset; i < end; i++) {
			
			char ch = hexString.charAt(i);
			
			if (allowSpaceChars && ch <= ' ') // ignored space/tab/'\r'/'\n'.
				continue;
			
			if (ch >= '0' && ch <= '9') 
				count++;
			else if (ch >= 'A' && ch <= 'F') 
				count++;
			else if (ch >= 'a' && ch <= 'f') 
				count++;
			else 
				return -1;
		}
		return count;
    }
    
    /**
     * @param hexString
     * @return
     */
    public static boolean isValidHexString(CharSequence hexString) {
    	
    	if (hexString == null)
    		return false;
    	
    	int count = countHexChars(hexString, 0, hexString.length(), true);
    	if (count == -1)
    		return false;
    	
    	return (count % 2) == 0;
    }
    
    /**
     * @param hexString
     * @param allowSpaceChars
     * @return
     */
    public static boolean isValidHexString(CharSequence hexString, boolean allowSpaceChars) {
    	
    	if (hexString == null)
    		return false;
    	
    	int count = countHexChars(hexString, 0, hexString.length(), allowSpaceChars);
    	if (count == -1)
    		return false;
    	
    	return (count % 2) == 0;
    }
    
    /**
     * @param hexString
     * @param offset
     * @param length
     * @param allowSpaceChars
     * @return
     */
    public static boolean isValidHexString(CharSequence hexString, int offset, int length, boolean allowSpaceChars) {
    	
    	if (hexString == null)
    		return false;
    	
    	int count = countHexChars(hexString, offset, length, allowSpaceChars);
    	if (count == -1)
    		return false;
    	
    	return (count % 2) == 0;
    }
    
    /**
     * @param buf
     * @return
     */
    public static String bytes2hexstr(byte[] bytes) {
    	return toHexString(bytes);
    }
    
    /**
     * @param bytes
     * @return
     */
    public static String bytes2hexstr(byte[] bytes, int offset, int length) {
    	return toHexString(bytes, offset, length);
    }
    
    /**
     * @param hexstr
     * @return
     */
    public static byte[] hexstr2bytes(String hexstr) {
    	return toByteArray(hexstr);
    }
    
    public static String sha_256(String data) {
    	if(data==null){
    		return "";
    	}
        byte[] bt = data.getBytes();
        MessageDigest md = null;
        try {
            md = MessageDigest.getInstance("SHA-256");
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        }
        md.update(bt);

       return HexUtils.bytes2hexstr(md.digest());
        
    }

}