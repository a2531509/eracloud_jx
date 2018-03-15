<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $grid;
	$(function(){
		$(document).keypress(function(event){
			if(event.keyCode == 13){
				query();
			}
		});
		
		createSysCode({id:"agtCertType",codeType:"CERT_TYPE",value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>"});
		$.autoComplete({
			id:"certNo",
			text:"cert_no",
			value:"name",
			table:"base_personal",
			keyColumn:"cert_no",
			//minLength:"1"
		},"name");
		$.autoComplete({
			id:"name",
			text:"name",
			value:"cert_no",
			table:"base_personal",
			keyColumn:"name",
			minLength:"1"
		},"certNo");
		$grid = createDataGrid({
			id:"dg",
			url:"cardIssuse/cardIssuseAction!oneCardIssuseQuery.action",
			pagination:false,
			//fitColumns:true,
			scrollbarSize:0,
			singleSelect:true,
			frozenColumns:[[
					{field:"APPLY_ID",title:"申领编号",checkbox:"ture"},
			  	    {field:"CUSTOMER_ID",title:"客户编号",sortable:true},
					{field:"NAME",title:"客户姓名",sortable:true,width : parseInt($(this).width() * 0.06)},
					{field:"CERTTYPE",title:"证件类型",sortable:true},
					{field:"CERT_NO",title:"证件号码",sortable:true,width : parseInt($(this).width() * 0.12)},
					{field:"CARDTYPE",title:"卡类型",sortable:true,width : parseInt($(this).width() * 0.06)},
					{field:"CARD_NO",title:"卡号",sortable:true,width : parseInt($(this).width() * 0.13)},
					{field:"MAKE_BATCH_ID",title:"批次号",sortable:true,width : parseInt($(this).width() * 0.07)},
					{field:"TASK_ID",title:"任务编号",sortable:true},
				]],
			  	columns:[[
					{field:"APPLYTYPE",title:"申领类型",sortable:true,width : parseInt($(this).width() * 0.08)},
					{field:"APPLYWAY",title:"申领方式",sortable:true,width : parseInt($(this).width() * 0.08)},
					{field:"APPLYSTATE",title:"申领状态",sortable:true,width : parseInt($(this).width() * 0.08)},
					{field:"IS_URGENT",title:"制卡方式",sortable:true,width : parseInt($(this).width() * 0.08)},
					{field:"RECV_CERT_TYPE",title:"领卡代理人证件类型",sortable:true},
					{field:"RECV_CERT_NO",title:"领卡代理人证件号码",sortable:true},
					{field:"RECV_NAME",title:"领卡代理人姓名",sortable:true},
					{field:"RECV_PHONE",title:"领卡代理人联系电话",sortable:true}
			    ]],onLoadSuccess:function(data){
		    	$("#form").form("reset");
		      	 $("input[type='checkbox']").each(function(){if(this.checked){ this.checked=false;}});
		      	 if(data.rows.length > 0){
		      		$(this).datagrid("selectRow",0);
		      	 }
	        }
		});
		$.addNumber("applyId");
		$.addNumber("agtTelNo");
	});
	function query(){
		if(dealNull($("#applyId").val()).length == 0 && dealNull($("#certNo").val()).length == 0 && dealNull($("#name").val()).length == 0){
			$.messager.alert("系统消息","请输入查询条件！","error");
			return;
		}
		$grid.datagrid('load',{
			queryType:'0',
			"apply.applyId":$("#applyId").val(),
			"person.certNo":$("#certNo").val(),
			"person.name":$("#name").val()
		});
	}
	function tosaveinfo(){
	    var row = $grid.datagrid('getSelected');
	    if(row){
			 $.messager.confirm('系统消息','您确定要发放所勾选的记录吗？',function(r){
	     		if(r){
	     			$.messager.progress({text:'数据处理中，请稍后....'});
	     			var params = getformdata("form");
	     			params["taskId"] = row.TASK_ID;
	     			params["applyId"] = row.APPLY_ID;
	     			params["rec.agtName"] = $("#agtName").val();
	  				$.post("cardIssuse/cardIssuseAction!saveOneCardIssuse.action",params,function(data,status){
	  						$.messager.progress('close');
					     	if(status == "success"){
								if(data.status == "0"){
									if(data.isHk){
										jAlert("该卡为换卡，发放后可以进行【换卡转钱包】操作", "info", function(){
											showReport("个人发放",data["dealNo"],function(){
												$.messager.progress({text:"正在进行加载，请稍后...."});
												window.history.go(0);
											});
										});
									} else {
										showReport("个人发放",data["dealNo"],function(){
											$.messager.progress({text:"正在进行加载，请稍后...."});
											window.history.go(0);
										});
									}
								}else{
									$.messager.alert("系统消息",data.errMsg,"error");
								}
					     	}else{
					     		$.messager.alert("系统消息","个人发放发生错误，请重新进行操作！","error");
					     	}
					},"json");
	     		}
	     	});
	    }else{
			 $.messager.alert('系统消息','请选择一条记录进行发放','error');
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
		$("#name").val(certinfo["name"]);
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
<n:initpage title="个人申领进行发放操作！">
	<n:center>
		<div id="tb" style="width:100%">
			<table class="tablegrid">
				<tr>
					<td class="tableleft">申领编号：</td>
					<td class="tableright"><input id="applyId" name="apply.applyId" type="text" class="textinput" maxlength="15"/></td>
					<td class="tableleft">证件号码：</td>
					<td class="tableright"><input id="certNo" name="person.certNo" type="text" class="textinput" maxlength="18"/></td>
					<td class="tableleft">客户姓名：</td>
					<td class="tableright"><input id="name" name="person.name" type="text" class="textinput" maxlength="30"/></td>
					<td style="text-align:center;">
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard()">读身份证</a>
						<a style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
						<shiro:hasPermission name="toOneCardIssuse">
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-ok"  plain="false" onclick="tosaveinfo();">确定</a>
						</shiro:hasPermission>
					</td>
				</tr>
			</table>
		</div>
	    <table id="dg" title="申领信息"></table>
	</n:center>
	<div id="test" data-options="region:'south',split:false,border:true" style="height:250px;width:auto;text-align:center;border-left:none;border-bottom:none;overflow:hidden;">
		<form id="form" method="post" class="datagrid-toolbar" style="height:100%">
			<h3 class="subtitle">代理人信息</h3>
			<table class="tablegrid">
				<tr>
					<th class="tableleft">代理人证件类型：</th>
					<td class="tableright"><input id="agtCertType" name="rec.agtCertType" type="text" class="easyui-combobox  easyui-validatebox"/> </td>
					<th class="tableleft">代理人证件号码：</th>
					<td class="tableright"><input id="agtCertNo" name="rec.agtCertNo" type="text" class="textinput easyui-validatebox" validtype="idcard" maxlength="18"/></td>
					<th class="tableleft">代理人姓名：</th>
					<td class="tableright"><input id="agtName" name="rec.agtName" type="text" class="textinput easyui-validatebox" maxlength="30"/></td>
					<th class="tableleft">代理人联系电话：</th>
					<td class="tableright" ><input id="agtTelNo" name="rec.agtTelNo" type="text" class="textinput easyui-validatebox" validtype="mobile" maxlength="11"/></td>
				</tr>
				<tr>
					<td class="tableleft" colspan="8" style="text-align:center;">
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readSMK2()">读市民卡</a>
						<a data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard2()">读身份证</a>
					</td>
				</tr>
			</table>
		</form>			
	</div>
</n:initpage>