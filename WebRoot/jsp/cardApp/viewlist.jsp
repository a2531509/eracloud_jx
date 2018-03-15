<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<script type="text/javascript">
var $dgview;
var $gridview;
var $girdtest;
var catId="";
$(function(){
});
function viewCAT(aa){
	catId = aa;
		$dgview = $("#dgview");
	
		$gridview=$dgview.datagrid({
			url:"/cardapply/cardApplyAction!view.action?catId="+aa,
			pagination:true,
			rownumbers:true,
			border:true,
			striped:true,
			fit:true,
			fitColumns:true,
			//scrollbarSize:0,
			singleSelect:false,
			pageSize:20,
			columns:[[
			      	{field:'NUM',sortable:true,checkbox:true},
			    	{field:'CUSTOMER_ID',title:'客户编号',sortable:true,width:parseInt($(this).width()*0.015)},
			    	{field:'NAME',title:'姓名',sortable:true,width:parseInt($(this).width()*0.01)},
			    	{field:'CERT_NO',title:'证件号码',sortable:true,width:parseInt($(this).width()*0.02)},
			    	{field:'BIRTHDAY',title:'出生年月',sortable:true,width:parseInt($(this).width()*0.009)},
			    	{field:'GENDER',title:'性别',sortable:true,width:parseInt($(this).width()*0.01)},
			    	{field:'NATION',title:'民族',sortable:true,width:parseInt($(this).width()*0.01)},
			    	{field:'CITYNAME',title:'所属城市',sortable:true,width:parseInt($(this).width()*0.01)},
			    	{field:'REGIONNAME',title:'所属区域',sortable:true,width:parseInt($(this).width()*0.01)},
			    	{field:'TOWNNAME',title:'村镇/社区',sortable:true,width:parseInt($(this).width()*0.02)},
			    	{field:'LETTER_ADDR',title:'通信地址',sortable:true,width:parseInt($(this).width()*0.02)},
			    	{field:'SURE_FLAG',title:'是否确认',sortable:true,width:parseInt($(this).width()*0.008)}
			    ]],toolbar:'#tbview',
				onLoadSuccess:function(data){
	            	  $("input[type=checkbox]").each(function(){
	        				this.checked = false;
	        		  });
	            	  if(data.status != 0){
	            		 $.messager.alert('系统消息',data.errMsg,'error');
	            	  }
          	}
		});
}

function query(){
	 $dgview.datagrid('load',{
			certNo:$("#certNo").val(),
			clientName:$("#name").val()
		});
}
	
</script>
  <div class="easyui-layout" data-options="fit:true">
	  <div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;">
		  <div id="tbview" style="padding:2px 0">
		  		<input type="hidden" name="catId" value="${catId}"/>
			<table cellpadding="0" cellspacing="0" style="width:100%">
				<tr >
					<td align="right" class="label_left" width="7%">身份证号：</td>
					<td align="left" class="label_right" width="15%"><input name="certNo"  class="textinput" id="certNo" type="text"/></td>
					<td align="right" class="label_left" width="7%">姓名：</td>
					<td align="left" class="label_right" width="15%"><input name="name"  class="textinput" id="name" type="text"/></td>
					<td style="padding-left:2px"><a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a></td>
				</tr>
			</table>
		</div>
  		 <table id="dgview" title="人员基本信息"></table>
     </div>
  </div>
