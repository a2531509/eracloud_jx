<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <base href="<%=basePath%>">
    <title>卡片解挂</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript">
	var $dg;
	var $temp;
	var $grid;
	$(function() {
		$(document).keypress(function(event){
			if(event.keyCode == 13){
				query();
			}
		});
		//createSysCode({id:"certType",codeType:"CERT_TYPE"});
		//createSysCode({id:"cardType",codeType:"CARD_TYPE"});
		createSysCode({id:"agtCertType",codeType:"CERT_TYPE",value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>"});
		$.autoComplete({
			id:"certNo",
			text:"cert_no",
			value:"name",
			table:"base_personal",
			keyColumn:"cert_no",
			//minLength:"1"
		});
		$dg = $("#dg");
		$grid=$dg.datagrid({
			url:"cardService/cardServiceAction!to_QueryJg.action",
			fit:true,
			pagination:false,
			rownumbers:true,
			border:false,
			striped:true,
			singleSelect:true,
			fitColumns:true,
			scrollbarSize:0,
			//0未启用1正常2口头挂失3书面挂失9注销
			columns:[ [ 
			           {field:'id',checkbox:true},
			            {field:'name',title:'姓名',width:parseInt($(this).width()*0.1),sortable:true},
			              {field:'certType',title:'证件类型',width:parseInt($(this).width()*0.1)},
			              {field:'certNo',title:'证件号码',width:parseInt($(this).width()*0.1),sortable:true},
			              {field:'cardType',title:'卡类型',width:parseInt($(this).width()*0.1)},
			              {field:'cardNo',title:'卡号',width:parseInt($(this).width()*0.1),sortable:true},
			              {field:'cardState',title:'卡状态',width:parseInt($(this).width()*0.1),align:'left'},
			              {field:'busType',title:'公交类型',width:parseInt($(this).width()*0.1)}
			              ]],
			   toolbar:'#tb',
               onLoadSuccess:function(data){
            	  if(data.status != 0){
            		  $.messager.alert('系统消息',data.errMsg,'error');
            	  }
            	  $("input[type=checkbox]").each(function(){
	      			  this.checked = false;
	      	      });
            	  if(data.rows.length > 0){
	          	      $(this).datagrid("selectRow",0);
	          	      $(this).datagrid("checkRow",0);
          	      }
            	  $("#form").form("reset");
               },onSelect:function(index,data){
               	    if(data == null)return;
    	            $("#accinfo").get(0).src = "/jsp/cardService/inneraccinfo.jsp?cardNo=" + data.cardNo;
    	            if($("#accinfodiv").css("display") != "block"){
    		            $("#accinfodiv").show();
    	            }
              	}
		});
	});
	//查询
	function query(){
		if($("#certNo").val().replace(/\s/g,'') == '' && $("#cardNo").val().replace(/\s/g,'') == ''){
			$.messager.alert("系统消息","请输入查询证件号码或是卡号！","error");
			return;
		}
		$dg.datagrid('load',{
			queryType:'0',//查询类型
			//certType:$("#certType").combobox('getValue'), 
			certNo:$('#certNo').val(), 
			//cardType:$("#cardType").combobox('getValue'),
			cardNo:$('#cardNo').val()
		});
	}
	function saveCardLos(){
		var row = $dg.datagrid('getSelected');
		if(row){
			$.messager.confirm('系统消息','您确定要对卡号为【' + row.cardNo + "】的卡片进行解挂吗？",function(is){
				if(is){
					$.messager.progress({text:'数据处理中，请稍后....'});
					$.post('cardService/cardServiceAction!toSaveJg.action',$('#form').serialize() + '&selectId=' + row.cardNo,function(data){
						$.messager.progress('close');
						$.messager.alert('系统消息',data.message,(data.status ? 'info':'error'),function(){
							if(data.status){
								$dg.datagrid('reload');
								showReport('卡片解挂',data.dealNo);
								$("#form").form("reset");
							}
						});
					},'json');
				}
			});
		}else{
			$.messager.alert("系统消息","请勾选一条卡信息进行解挂！","error");
		}
	}
	function readIdCard(){
		$.messager.progress({text:'正在获取证件信息，请稍后....'});
		var certinfo = getcertinfo();
		if(dealNull(certinfo["cert_No"]).length < 15){			
			$.messager.progress('close');
			return;
		}
		$.messager.progress('close');
		$("#certType").combobox("setValue",'1');
		$("#certNo").val(certinfo["cert_No"]);
		query();
	}
	function readIdCard2(){
		$.messager.progress({text:'正在获取证件信息，请稍后....'});
		var certinfo = getcertinfo();
		if(dealNull(certinfo["cert_No"]).length < 15){			
			$.messager.progress('close');
			return;
		}
		$.messager.progress('close');
		$("#agtCertType").combobox("setValue",'1');
		$("#agtCertNo").val(certinfo["cert_No"]);
		$("#agtName").val(certinfo["name"]);
	}
	function readSMK2(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var queryCertInfo = getcardinfo();
		if(dealNull(queryCertInfo["card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + queryCertInfo["errMsg"],"error");
			$.messager.progress('close');
			return;
		}
		$.messager.progress("close");
		$("#agtCertType").combobox("setValue","1");
		$("#agtCertNo").val(dealNull(queryCertInfo["cert_No"]));
		$("#agtName").val(dealNull(queryCertInfo["name"]));
	}
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="overflow: hidden; padding: 0px;">
		<div class="well well-small datagrid-toolbar">
			<span class="badge">提示</span><span>在此你可以对<span class="label-info"><strong>挂失的卡片</strong></span>进行解挂操作!</span>
		</div>
	</div>
	<div id="p_layouts" data-options="region:'center',split:false,border:true" style="padding:0px;width:auto;border-bottom:none;border-left:none;">
			<div id="tb" style="padding:2px 0">
				<form id="searchFrom">
					<table class="tablegrid">
						<tr>
							<!-- <td style="padding-left:3px">证件类型：</td>
							<td style="padding-left:3px"><input id="certType" type="text" class="easyui-combobox  easyui-validatebox" name="certType" value="1" style="width:174px;cursor:pointer;"/></td> -->
							<td class="tableleft">证件号码：</td>
							<td class="tableright"><input name="certNo"  class="textinput" id="certNo" type="text" maxlength="18"/></td>
							<!-- <td style="padding-left:3px">卡类型：</td>
							<td style="padding-left:3px"><input id="cardType" type="text" class="easyui-combobox  easyui-validatebox" name="cardType" style="width:174px;"/></td> -->
							<td class="tableleft">卡号：</td>
							<td class="tableright"><input name="cardNo"  class="textinput" id="cardNo" type="text" maxlength="20"/></td>
							<td style="padding-left:3px">
								<shiro:hasPermission name="cardLostSave">
									<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard()">读身份证</a>
									<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
									<a href="javascript:void(0);"  class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-save'" plain="false" onclick="saveCardLos();">确定</a>
								</shiro:hasPermission>
							</td>
						</tr>
					</table>
				</form>
			</div>
	  		<table id="dg" title="用户信息"></table>
	  </div>
	 <div id="test" data-options="region:'south',split:false,border:true" style="height:300px; width:100%;text-align:center;overflow:hidden;border-bottom:none;border-left:none;">
	  		<form id="form" method="post" class="datagrid-toolbar" style="width:100%;height:100%;">
	  			<div style="width:100%;display:none;" id="accinfodiv">
		  			<h3 class="subtitle">账户信息</h3>
		  			<iframe name="accinfo" id="accinfo"  width="100%" style="border:none;height:52px;padding:0px;margin:0px;"></iframe>
				</div>
	  			<h3 class="subtitle">代理人信息</h3>
				 <table width="100%" class="tablegrid">
					 <tr>
						<th class="tableleft">代理人证件类型：</th>
						<td class="tableright"><input id="agtCertType" name="rec.agtCertType" type="text" class="easyui-combobox  easyui-validatebox"  value="1" style="width:174px;"/> </td>
						<th class="tableleft">代理人证件号码：</th>
						<td class="tableright"><input id="agtCertNo" name="rec.agtCertNo" type="text" class="textinput easyui-validatebox"  validtype="idcard" maxlength="18"/></td>
						<th class="tableleft">代理人姓名：</th>
						<td class="tableright"><input id="agtName" name="rec.agtName" type="text" class="textinput easyui-validatebox"   maxlength="30" /></td>
					 	<th class="tableleft">代理人联系电话：</th>
						<td class="tableright"><input name="rec.agtTelNo" id="rec.agtTelNo" type="text" class="textinput easyui-validatebox"  maxlength="11" validtype="mobile"/></td>
					</tr>
					<tr>
						<td class="tableleft" colspan="8">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readSMK2()">读市民卡</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard2()">读身份证</a>
						</td>
					</tr>
				 </table>
			</form>			
	  </div>
</body>
</html>