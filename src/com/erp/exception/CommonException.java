package com.erp.exception;

import com.erp.util.Tools;

public class CommonException extends RuntimeException{
	 public CommonException()
	    {
	        message = "";
	    }

	    public CommonException(String msg)
	    {
	        super(msg);
	        message = "";
	    }

	    public CommonException(Exception ex)
	    {
	        super(ex.toString());
	        message = "";
	    }

	    public CommonException(String s, Throwable ex)
	    {
	        super(s);
	        message = "";
	        exception = ex;
	    }

	    public CommonException(int errorCode, String msg)
	    {
	        super(msg);
	        message = "";
	        this.errorCode = errorCode;
	    }

	    public CommonException(int errorCode, String msg, Throwable e)
	    {
	        super(msg);
	        message = "";
	        this.errorCode = errorCode;
	        exception = e;
	    }

	    public int getErrorCode()
	    {
	        return errorCode;
	    }

	    public String getMessage()
	    {
	        if(exception != null)
	            message = (new StringBuilder(String.valueOf(super.getMessage()))).append(exception.getMessage()).toString();
	        else
	            message = super.getMessage();
	        message = message.replaceAll("\n\r", "").replaceAll("\n", "").replaceAll("\"", "'");
	        message = Tools.replace(message, "\"", "'");
	        return message;
	    }

	    public void printStackTrace()
	    {
	        if(exception != null)
	            exception.printStackTrace();
	    }

	    private static final long serialVersionUID = 2386204195595237758L;
	    protected Throwable exception;
	    protected int errorCode;
	    protected String message;
}
