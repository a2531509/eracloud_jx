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
@SuppressWarnings("serial")
public class NorthAreaTag extends TagSupport {
	private String id;
	private String cssClass;
	private String cssStyle;
	private String layoutOptions;
	private String title;
	
	@Override
	public int doEndTag() throws JspException {
		super.doEndTag();
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
			if(!Tools.processNull(this.cssClass).equals("")){
				sb.append("class = \"" + this.cssClass + "\" ");
			}
			sb.append("data-options=\"region:'north',border:false");
			if(!Tools.processNull(layoutOptions).equals("")){
				sb.append("," + layoutOptions);
			}
			sb.append("\" ");
			sb.append("style=\"height:auto;overflow:hidden;");
			if(!Tools.processNull(cssStyle).equals("")){
				sb.append(this.cssStyle);
			}
			sb.append("\" ");
			sb.append(">");
			sb.append("<div class=\"well well-small datagrid-toolbar\" style=\"margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;\">");
			sb.append("<span class=\"badge\">提示</span><span>在此你可以<span class=\"label-info\"><strong>");
			if(!Tools.processNull(title).equals("")){
				sb.append(title);
			}
			sb.append("</strong></span></span>");
			sb.append("</div></div>");
			out.write(sb.toString());
		}catch(Exception e){
			
		}
		return SKIP_BODY;
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
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
}
