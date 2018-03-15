/**
 * 
 */
package com.erp.tag;

import java.util.Enumeration;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.PageContext;
import javax.servlet.jsp.tagext.Tag;
import javax.servlet.jsp.tagext.TagSupport;

import com.erp.util.Tools;
public class InitPageTag extends TagSupport {
	private static final long serialVersionUID = 1L;
	private String title;
	@Override
	public int doAfterBody() throws JspException {
		// TODO Auto-generated method stub
		return super.doAfterBody();
	}

	@Override
	public int doEndTag() throws JspException {
		try{
			JspWriter out = this.pageContext.getOut();
			StringBuffer sb = new StringBuffer();
			sb.append("</body>");
			sb.append("</html>");
			out.print(sb.toString());
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
			sb.append("</head>");
			sb.append("<body class=\"easyui-layout\" data-options=\"fit:true\">");
			if(!Tools.processNull(title).equals("")){
				sb.append("<div data-options=\"region:'north',border:false\" style=\"height:auto;overflow:hidden;\">");
				sb.append("<div class=\"well well-small datagrid-toolbar\" style=\"margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;\">");
				sb.append("<span class=\"badge\">提示</span><span>在此你可以对<span class=\"label-info\"><strong>");
				sb.append(title);
				sb.append("</strong></span></span>");
				sb.append("</div></div>");
			}
			out.write(sb.toString());
		}catch(Exception e){
			
		}
		return EVAL_BODY_INCLUDE;
	}

	@Override
	public String getId() {
		// TODO Auto-generated method stub
		return super.getId();
	}

	@Override
	public Tag getParent() {
		// TODO Auto-generated method stub
		return super.getParent();
	}

	@Override
	public Object getValue(String k) {
		// TODO Auto-generated method stub
		return super.getValue(k);
	}

	@Override
	public Enumeration<String> getValues() {
		// TODO Auto-generated method stub
		return super.getValues();
	}

	@Override
	public void release() {
		// TODO Auto-generated method stub
		super.release();
	}

	@Override
	public void removeValue(String k) {
		// TODO Auto-generated method stub
		super.removeValue(k);
	}

	@Override
	public void setId(String id) {
		// TODO Auto-generated method stub
		super.setId(id);
	}

	@Override
	public void setPageContext(PageContext pageContext) {
		// TODO Auto-generated method stub
		super.setPageContext(pageContext);
	}

	@Override
	public void setParent(Tag t) {
		// TODO Auto-generated method stub
		super.setParent(t);
	}

	@Override
	public void setValue(String k, Object o) {
		// TODO Auto-generated method stub
		super.setValue(k, o);
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}
}
