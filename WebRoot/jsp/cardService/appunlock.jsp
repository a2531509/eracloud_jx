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
    <title>卡片应用解锁 </title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript">
		var finalcostfee = "${costFee}";
		var $dg;
		var $grid;
		var cardinfo;
		$(function(){
			$(document).keypress(function(event){
				if(event.keyCode == 13){
					toSearch();
				}
			});
			
			if("${defaultErrMsg}" != ""){
				$.messager.alert("系统消息","${defaultErrMsg}","error");
			}
			$("#curState").combobox({
				width:174,
				valueField:'codeValue',
				editable:false,
			    textField:'codeName',
			    disabled:true,
			    panelHeight: 'auto',
			    data:[{codeValue:'0',codeName:'正常'},{codeValue:'1',codeName:'锁定'}]
			});
			createSysCode({id:"cardType",codeType:"CERT_TYPE"});
			createSysCode({id:"agtCertType",codeType:"CERT_TYPE",value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>"});
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url:"cardService/cardServiceAction!hkCardQuery.action",
				fit:true,
				pagination:false,
				rownumbers:true,
				border:false,
				striped:true,
				singleSelect:true,
				fitColumns:true,
				scrollbarSize:0,
				columns:[[ 
						{field:'V_V',checkbox:true},
						{field:'CUSTOMER_ID',title:'客户编号',sortable:true,width:parseInt($(this).width() * 0.1)},
						{field:'NAME',title:'姓名',sortable:true,width:parseInt($(this).width() * 0.08)},
						{field:'CERT_NO',title:'证件号码',sortable:true,width:parseInt($(this).width() * 0.18)},
						{field:'CERTTYPE',title:'证件类型',sortable:true,width:parseInt($(this).width() * 0.1)},
						{field:'GENDERS',title:'性别',sortable:true,width:parseInt($(this).width() * 0.05)},
						{field:'CARD_NO',title:'卡号',sortable:true,width:parseInt($(this).width() * 0.2)},
						{field:'CARDTYPE',title:'卡类型',sortable:true,width:parseInt($(this).width() * 0.08)},
						{field:'CARDSTATE',title:'卡状态',sortable:true,width:parseInt($(this).width() * 0.1)},
						{field:'START_DATE',title:'启用日期',sortable:true,width:parseInt($(this).width() * 0.1)},
						{field:'VALID_DATE',title:'有效期',sortable:true,width:parseInt($(this).width() * 0.1)},
						{field:'BUSTYPE',title:'公交类型',sortable:true,width:parseInt($(this).width() * 0.08)}
				]],
			    toolbar:'#tb',
                onLoadSuccess:function(data){
                	$("input[type=checkbox]").each(function(){
        				this.checked = false;
        			});
            	    if(data.status != 0){
            		    $.messager.alert('系统消息',data.errMsg,'error');
            	    }
            	    if(data.rows.length > 0){
            	    	$(this).datagrid("selectRow",0);
            	    }
            	    $("#form").form("reset");
                },onSelect:function(index,data){
               	    if(data == null)return;
    	            $("#accinfo").get(0).src = "jsp/cardService/inneraccinfo.jsp?cardNo=" + data.CARD_NO;
    	            if($("#accinfodiv").css("display") != "block"){
    		            $("#accinfodiv").show();
    	            }
              	}
			});
		});
		function tosaveunlock(){
			var row = $dg.datagrid('getSelected');
			if(row){
				if(cardinfo){
					if(dealNull(cardinfo['use_Version']).length > 0){
						$.messager.alert("系统消息","该卡已是【正常】状态无需重复解锁！","error");
						return;
					}
				}
				if(row.CARD_STATE == '<s:property value="@com.erp.util.Constants@CARD_STATE_ZX"/>'){
					$.messager.alert("系统消息","卡片应用解锁发生错误：此卡已经注销不能进行解锁！当前状态【" + row.CARDSTATE + "】","error");
					return;
				}
				$.messager.confirm('系统消息','您确定要对【' + row.NAME + '】卡号为【' + row.CARD_NO + '】的卡进行应用解锁吗？',function(is){
					if(is){
						$.messager.progress({text:'数据处理中，请稍后....'});
						$.post('cardService/cardServiceAction!saveAppUnlockHjl.action',$('#form').serialize() + '&rec.cardNo=' + row.CARD_NO + "&cardAmt=" + $("#cardAmt").val(),function(data,status){
							if(status == 'success'){
								if(data.status  == '0'){
									if(cardunlock()){//
										cardinfo = getcardinfo();
										$("#curState").combobox("setValue","0");
										cardunlockconfirm(data.dealNo);
									}else{
										cardunlockcancel(data.dealNo);
									}
								}else{
									$.messager.progress('close');
									$.messager.alert("系统消息","卡片应用解锁发生错误：" + data.msg,"error");
								}
							}else{
								$.messager.progress('close');
								$.messager.alert("系统消息","卡片应用解锁发生错误：请拿起并重新放置好卡片，再次进行读取！","error");
							}
						},'json');
					}
				});
			}else{
				$.messager.alert("系统消息","请勾选一条记录信息进行卡片应用解锁","error");
			}
		}
		function readcard(){
			$.messager.progress({text : '正在获取卡信息,请稍后...'});
			cardinfo = getcardinfo();
			$.messager.progress('close');
			if(dealNull(cardinfo['flow_No']).length == 0){
				$.messager.alert('系统消息','读卡出现错误，请拿起并重新放置好卡片，再次进行读取！' + cardinfo["errMsg"],'error');
				return;
			}else{
				if(dealNull(cardinfo['use_Version']).length > 0){
					$("#curState").combobox("setValue","0");
				}else{
					$("#curState").combobox("setValue","1");
				}
				$("#cardNo").val(cardinfo['flow_No']);
				$("#cardAmt").val((parseFloat(isNaN(cardinfo['wallet_Amt']) ? 0:cardinfo['wallet_Amt'])/100).toFixed(2));
				toSearch();
			}
		}
		//写卡
		function cardunlock(){
			return CardAppunBlock1001();
		}
		//确认
		function cardunlockconfirm(dealNo){
			$.post('cardService/cardServiceAction!saveAppUnlockHjlConfirm.action',{'rec.dealNo':dealNo},function(data,status){
				$.messager.progress('close');
				$.messager.alert('系统消息',"卡片应用解锁成功！","info"); 
			});
		}
		//冲正
		function cardunlockcancel(dealNo){
			$.post('cardService/cardServiceAction!saveAppUnlockHjlCancel.action',{'rec.dealNo':dealNo},function(data,status){
				$.messager.progress('close');
				$.messager.alert('系统消息',"卡片应用解锁发生错误：请拿起并重新放置好卡片重新进行操作！","error");
			});
		}
		//根据查询条件查询卡信息
		function toSearch(){
			if($("#cardNo").val().replace(/\s/g,'') == ''){
				$.messager.alert("系统消息","请输入卡号进行查询！","error");
				return;
			}
			if($("#accinfodiv").css("display") == "block"){
				accinfo.window.deleteAllData();
			}
			$dg.datagrid('load',{
				queryType:'0',//查询类型
				cardType:$("#cardType").combobox('getValue'),
				cardNo:$('#cardNo').val()
			});
		}
		function readIdCard(){
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
	</script>
</head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="overflow: hidden; padding: 0px;">
		<div class="well well-small datagrid-toolbar">
			<span class="badge">提示</span>
			<span>在此你可以对<span class="label-info"><strong>卡片应用进行解锁操作！</strong></span></span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="padding:0px;width:auto;border-bottom:none;border-left:none;">
			<div id="tb" style="padding:2px 0">
				<form id="searchFrom">
					<table class="tablegrid">
						<tr>
							<td class="tableleft">卡类型：</td>
							<td class="tableright"><input id="cardType" type="text" class="easyui-combobox  easyui-validatebox" name="cardType"/></td>
							<td class="tableleft">卡号：</td>
							<td class="tableright"><input name="cardNo"  class="textinput" id="cardNo" type="text" readonly="readonly"/></td>
							<td class="tableleft">卡余额：</td>
							<td class="tableright"><input id="cardAmt" type="text" class="textinput  easyui-validatebox" name="cardAmt" readonly="readonly"/></td>
							<td class="tableright">
								<a  data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readcard()">读卡</a>
								<a  data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="toSearch()">查询</a>
								<a href="javascript:void(0);"  class="easyui-linkbutton" data-options="plain:false,iconCls:'icon-save'" plain="false" onclick="tosaveunlock();">应用解锁</a>
							</td>
						</tr>
					</table>
				</form>
			</div>
	  		<table id="dg" title="用户信息"></table>
	  </div>
	 <div id="test" data-options="region:'south',split:false,border:true" style="height:300px; width:auto;text-align:center;overflow:hidden;border-bottom:none;border-left:none;">
	  		<form id="form" method="post" class="datagrid-toolbar" style="height:100%">
	  			<div style="width:100%;display:none;" id="accinfodiv">
		  			<h3 class="subtitle">账户信息</h3>
		  			<iframe name="accinfo" id="accinfo"  width="100%" style="border:none;height:52px;padding:0px;margin:0px;"></iframe>
				</div>
	  			<h3 class="subtitle">代理人信息</h3>
				<table width="100%" class="tablegrid">
				 	 <tr>
				 	 <td class="tableleft">当前卡片状态：</td>
						<td class="tableright"><input id="curState" type="text" class="easyui-combobox  easyui-validatebox" name="curState" value="0" style="width:174px;"/> </td>
						<td class="tableleft">代理人证件类型：</td>
						<td class="tableright"><input id="agtCertType" type="text" class="easyui-combobox  easyui-validatebox" name="rec.agtCertType" value="1" style="width:174px;"/> </td>
						<td class="tableleft">代理人证件号码：</td>
						<td class="tableright"><input name="rec.agtCertNo"  class="textinput easyui-validatebox" id="agtCertNo" type="text" maxlength="18" validtype="idcard" /></td>
					</tr>
					<tr>
						<td class="tableleft">代理人姓名：</td>
						<td class="tableright"><input name="rec.agtName" id="agtName" type="text" class="textinput easyui-validatebox"  maxlength="30"/></td>
					 	<td class="tableleft">代理人联系电话：</td>
						<td class="tableright"><input name="rec.agtTelNo" id="agtTelNo" type="text" class="textinput easyui-validatebox" maxlength="11"  validtype="mobile"/></td>
						<td class="tableright" colspan="2">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard()">读身份证</a>
						</td>
					</tr>
				</table>
			</form>	
	  </div>
</body>
</html>