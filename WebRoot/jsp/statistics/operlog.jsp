<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<%-- 
#*---------------------------------------------#
# Template for a JSP
# @version: 1.2
# @author: yangn
# @author: Jed Anderson
# @describle:功能说明：SysActionLog 操作日志查询
#---------------------------------------------#
--%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<base href="<%=basePath%>">
<title>操作日志查询</title>
<meta http-equiv="pragma" content="no-cache">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="expires" content="0">    
<%@ include file="../../layout/script.jsp"%>
<script type="text/javascript">
	var $dg;
	$(function() {
		createSysBranch("branchId","userId");
		$("#dealCode").combobox({ 
		    url:"statistical/statisticalAnalysisAction!getAllDealCodes.action",
		    editable:false,
		    cache: false,
		    panelWidth:300,
		    groupField:"GCODE",
		    width:174,
		   // panelHeight: 'auto',
		    valueField:'CODE_VALUE',   
		    textField:'CODE_NAME',
		    groupFormatter:function(value){
		    	return "<span style=\"color:red;font-weight:600;font-style:italic;\">" + value + "</span>";
		    }
		});
		$("#userId").combobox({ 
		    url:"commAction!getAllOperators.action",
		    editable:false,
		    cache: false,
		    width:174,
		    panelHeight: 'auto',
		    valueField:'user_Id',   
		    textField:'user_Name',
		    onLoadSuccess:function(){
		    	var options = $(this).combobox('getData');
		    	var len = options.length;
		    	if(len > 0){
		    		$(this).combobox('setValue',options[0].user_Id);
		    	}
		    }
		}); 
		$dg = $("#dg");
		$grid=$dg.datagrid({
			url : "statistical/statisticalAnalysisAction!operLogQuery.action",
			fit:true,
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			pageSize:20,
			singleSelect:true,
			autoRowHeight:true,
			showFooter: true,
			scrollbarSize:0,
			//fitColumns:true,
			//scrollbarSize:0,
			frozenColumns:[[
					{field:'DEAL_NO',title:'流水号',sortable:true},
					{field:'DEAL_CODE',title:'交易代码',sortable:true,width:parseInt($(this).width() * 0.06)},
					{field:'DEAL_CODE_NAME',title:'交易名称',sortable:true,width:parseInt($(this).width() * 0.14)}
			                
			]],
			columns :[[
					{field:'ORG_ID',title:'机构编号',sortable:true},
					{field:'ORG_NAME',title:'机构名称',sortable:true},
					{field:'CO_ORG_ID',title:'合作机构编号',sortable:true},
					{field:'CO_ORG_NAME',title:'合作机构名称',sortable:true},
					{field:'FULL_NAME',title:'网点',sortable:true},
					{field:'NAME',title:'柜员',sortable:true},
					{field:'IP',title:'客户端IP',sortable:true},
					{field:'DEALTIME',title:'操作时间',sortable:true,width:parseInt($(this).width() * 0.12)},
					{field:'MESSAGE',title:'说明',sortable:true},
					{field:'FUNC_URL',title:'请求路径',sortable:true},
					{field:'IN_OUT_DATA',title:'请求参数',sortable:true,formatter:function(value,row,index){
						if(value.length > 15){
							return "<div id=\"t" + index + "\" style=\"width:100%;height:100%\">" + value.substring(0,15) + "  ...</div>";
						}else{
							return "<div id=\"t" + index + "\" style=\"width:100%;height:100%\">" + value + "</div>";
						}
					}},
					{field:'NOTE',title:'备注',sortable:true}
			  ]],
			  toolbar:'#tb',
	          onLoadSuccess:function(data){
	        	  $("input[type=checkbox]").each(function(){
	    				this.checked = false;
	    		  });
	        	  if(data.status != "0"){
	        		 $.messager.alert('系统消息',data.errMsg,'error');
	        	  }
	          },
	          onClickCell:function(index,field,value){
	        	  if(field == "IN_OUT_DATA"){
	        		  $("#t" + index).tooltip({position:'top', 
			  	            content: $('<div></div>'),
			  	            onShow: function(){
			  	            	var t = $(this);
								t.tooltip('tip').unbind().bind('mouseenter', function(){
									t.tooltip('show');
								}).bind('mouseleave', function(){
									t.tooltip('hide');
								});
			  	            },
			  	          	onUpdate: function(con){
								con.panel({
									width: 200,
									height: 'auto',
									border: false,
									content:dealValue(value)
								});
							},
			  	          	onHide:function(){
			  	        	  $(this).tooltip("destroy");
			  	          	}
        			  });
	        		  $("#t" + index).tooltip("show");
	        	  }
	          }
		});
	});
	function autoCom(){
		if($("#coOrgId").val() == ""){
			$("#coOrgName").val("");
		}
		$("#coOrgId").autocomplete({
			position: {my:"left top",at:"left bottom",of:"#coOrgId"},
		    source: function(request,response){
			    $.post('cooperationAgencyManager/cooperationAgencyAction!initAutoComplete.action',{"co.coOrgId":$("#coOrgId").val(),"queryType":"1"},function(data){
			    	response($.map(data.rows,function(item){return {label:item.label,value:item.text};}));
			    },'json');
		    },
		    select: function(event,ui){
		      	$('#coOrgId').val(ui.item.label);
		        $('#coOrgName').val(ui.item.value);
		        return false;
		    },
	      	focus:function(event,ui){
		        return false;
	      	}
	    }); 
	}
	function autoComByName(){
		if($("#coOrgName").val() == ""){
			$("#coOrgId").val("");
		}
		$("#coOrgName").autocomplete({
		    source:function(request,response){
		        $.post('cooperationAgencyManager/cooperationAgencyAction!initAutoComplete.action',{"co.coOrgName":$("#coOrgName").val(),"queryType":"0"},function(data){
		            response($.map(data.rows,function(item){return {label:item.text,value:item.label};}));
		        },'json');
		    },
		    select: function(event,ui){
		    	$('#coOrgId').val(ui.item.value);
		        $('#coOrgName').val(ui.item.label);
		        return false;
		    },
		    focus: function(event,ui){
		        return false;
		    }
	    }); 
	}
	function dealValue(value){
		var index,firststring = "";secstring = "";
		index = value.indexOf("Params:");
		firststring = value.substring(0,index);
		secstring = value.substring(index).replace("Params:","");
		return firststring.replace("Action:","Action:</br>").replace("Method:","</br>Method:</br>") + JSON.stringify(eval("(" + secstring +  ")")," ");
	}
	function query(){
		var params = getformdata("operLogQuery");
		if(params["isNotBlankNum"] == 0){
			$.messager.alert("系统消息","查询不能全部为空，请至少输入或选择一个参数信息！","warning");
			return;
		}
		params["queryType"] = 0;
		params["beginTime"] = $("#beginTime").val().replace(/\D/g,'');
		params["endTime"] = $("#endTime").val().replace(/\D/g,'');
		params["accKind"] = $("#coOrgName").val();
		params["sysLog.ip"] = $("#ip").val().replace(/\D/g,"");
		$dg.datagrid('load',params);
	}
</script>
</head>
<body class="easyui-layout">
	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span><span>在此你可以对<span class="label-info"><strong>系统操作日志进行查询操作！</strong></span></span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="height:auto;overflow:hidden;border-left:none;border-bottom:none;">
		<div id="tb" style="padding:2px 0">
			<form id="operLogQuery">
				<table cellpadding="0" cellspacing="0" class="tablegrid" style="width:100%">
					<tr>
						<td class="tableleft">流水号：</td>
						<td class="tableright"><input id="dealNo" type="text"  class="textinput easyui-validatebox" name="sysLog.dealNo"/></td>
						<td class="tableleft">所属网点：</td>
						<td class="tableright"><input id="branchId" type="text" class="textinput" name="sysLog.brchId"/></td>
						<td class="tableleft">柜员：</td>
						<td class="tableright"><input id="userId" type="text" class="textinput" name="sysLog.userId"/></td>
					</tr>
					<tr>
						<td class="tableleft">IP地址：</td>
						<td class="tableright"><input id="ip" type="text"  class="textinput" name="sysLog.ip"/></td>
						<td class="tableleft">合作机构编号：</td>
						<td class="tableright"><input id="coOrgId" type="text" class="textinput" name="sysLog.coOrgId" onkeydown="autoCom()" onkeyup="autoCom()"/></td>
						<td class="tableleft">合作机构名称：</td>
						<td class="tableright"><input id="coOrgName" type="text" class="textinput" name="accKind" onkeydown="autoComByName()" onkeyup="autoComByName()"/></td>
					</tr>
					<tr>
						<td class="tableleft">业务类型：</td>
						<td class="tableright"><input id="dealCode" type="text" class="textinput" name="sysLog.dealCode"/></td>
						<td class="tableleft">起始日期：</td>
						<td class="tableright"><input id="beginTime" type="text" name="beginTime" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss',qsEnabled:false,maxDate:'%y-%M-%d 0:0:0'})"/></td>
						<td class="tableleft">结束日期：</td>
						<td class="tableright">
							<input id="endTime" type="text"  name="endTime" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss',qsEnabled:false,maxDate:'%y-%M-%d'})"/>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="业务操作日志信息"></table>
	</div>
</body>
</html>
