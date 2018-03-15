/**
 * 
 */
package com.erp.tag;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.TagSupport;

import com.erp.util.Tools;

/**
 * @author Administrator
 *
 */
public class LayoutTag extends TagSupport {
	private static final long serialVersionUID = 1L;
	private String id;
	private String cssClass;
	private String cssStyle;
	private String layoutOptions;
	@Override
	public int doEndTag() throws JspException {
		try{
			JspWriter out = this.pageContext.getOut();
			out.print("</div>");
		}catch (Exception e) {
			 throw new JspException(e.getMessage());
		}
		return EVAL_PAGE;
	}
	
	@Override
	public int doStartTag() throws JspException {
		try{
			JspWriter out = this.pageContext.getOut();
			StringBuffer sb = new StringBuffer();
			sb.append("<div ");
			if(!Tools.processNull(id).equals("")){
				sb.append("id = \"" + this.id + "\" ");
			}
			sb.append("class=\"easyui-layout");
			if(!Tools.processNull(this.cssClass).equals("")){
				sb.append(" " + this.cssClass);
			}
			sb.append("\" ");
			sb.append("data-options=\"fit:true,border:false");
			if(!Tools.processNull(layoutOptions).equals("")){
				sb.append("," + layoutOptions);
			}
			sb.append("\" ");
			if(!Tools.processNull(cssStyle).equals("")){
				sb.append("style=\"");
				sb.append(this.cssStyle);
			}
			sb.append(">");
			out.write(sb.toString());
		}catch(Exception e){
			
		}
		return EVAL_BODY_INCLUDE;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getCssClass() {
		return cssClass;
	}

	public void setCssClass(String cssClass) {
		this.cssClass = cssClass;
	}

	public String getCssStyle() {
		return cssStyle;
	}

	public void setCssStyle(String cssStyle) {
		this.cssStyle = cssStyle;
	}

	public String getLayoutOptions() {
		return layoutOptions;
	}

	public void setLayoutOptions(String layoutOptions) {
		this.layoutOptions = layoutOptions;
	}
}
