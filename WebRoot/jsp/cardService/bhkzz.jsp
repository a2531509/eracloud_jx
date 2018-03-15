<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<!-- 换卡转钱包 -->
<script type="text/javascript">
	var cycleNum0 = 0,cycleNum1 = 0,cycleNum2 = 0;
	var finalcyclenum = 2;
	var $grid;
	var $cardinfo;
	var cardmsg;
	$(function(){
		$(document).keypress(function(event){
			if(event.keyCode == 13){
				query();
			}
		});
		
		createSysCode({
			id:"agtCertType",
			codeType:"CERT_TYPE",
			value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>"
		});
		$cardinfo = createDataGrid({
			id:"cardinfo",
			url:"cardService/cardServiceAction!toBhkZzQuery.action",
			fit:true,
			pagination:false,
			rownumbers:true,
			border:false,
			striped:true,
			singleSelect:true,
			checkOnSelect:true,
			scrollbarSize:0,
			fitColumns:true,
			columns:[[
				{field:"V_V",checkbox:true},
	        	{field:"CUSTOMER_ID",title:"客户编号",sortable:true,width:parseInt($(this).width() * 0.08)},
	        	{field:"NAME",title:"姓名",sortable:true,width:parseInt($(this).width() * 0.08)},
	        	{field:"CERT_TYPE",title:"证件类型",sortable:true,width:parseInt($(this).width() * 0.08)},
	        	{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width() * 0.14)},
	        	{field:"CARD_TYPE",title:"卡类型",sortable:true,width:parseInt($(this).width() * 0.06)},
	        	{field:"CARD_NO",title:"卡号",sortable:true,width:parseInt($(this).width() * 0.15)},
	        	{field:"CARDSTATE",title:"卡状态",sortable:true,width:parseInt($(this).width() * 0.05)},
	        	{field:"BUSTYPE",title:"公交类型",sortable:true,width:parseInt($(this).width() * 0.06)},
	        	//{field:"REDEEM_FLAG",title:"是否返还余额",sortable:true,width:parseInt($(this).width() * 0.08)},
	        	{field:"RSV_ONE",title:"钱包账户退还方式",sortable:false},
	        	{field:"PRV_BAL",title:"卡面余额",sortable:false}
	        ]],
            onLoadSuccess:function(data){
	           	if(data.status != 0){
	           	 	$.messager.alert("系统消息",data.errMsg,"error");
	           	}
	           	if(data.rows.length > 0 ){
		           	$(this).datagrid("selectRow",0);
	           	}
	           	$("#form").form("reset");
            },
            onSelect:function(index,data){
            	if(data == null)return;
	            $("#accinfo").get(0).src = "jsp/cardService/inneraccinfo.jsp?accKind=01&bal_rslt=true&fhrq=true&cardNo=" + data.CARD_NO;
	            if($("#accinfodiv").css("display") != "block"){
		            $("#accinfodiv").show();
	            }
            }
		});		
	});
	function query(){
		if($("#cardNo").val().replace(/\s/g,"") == ""){
			jAlert("请先进行读卡再进行查询！");
			return;
		}
		$("#totalAmt").val("0");
		if($("#accinfodiv").css("display") == "block"){
			accinfo.window.deleteAllData();
		}
		$("input[type=checkbox]").each(function(){
			this.checked = false;
		});
		$cardinfo.datagrid("load",{
			queryType:"0",
			cardNo:$("#cardNo").val(),
			selectId:$("#cardTrCount").val(),
            cardAmt:$("#cardAmt").val()
		});
	}
	function calFee(){
		var tempFee = 0;
		var curcard = $("#cardinfo").datagrid("getSelected");
		if(curcard){
			var allacc = accinfo.window.getAllData();
			if(allacc && allacc.length > 0){
				for(var i = 0;i < allacc.length;i++){
					if(allacc[i].ACC_KIND == "01" && curcard.RSV_ONE_FLAG == "0" && allacc[i].BAL_RSLT_FLAG == "0"){//RSV_ONE   
						tempFee = (Number(parseFloat(tempFee).toFixed(2)) + Number(parseFloat(curcard.PRV_BAL).toFixed(2)));
					}else if(allacc[i].BAL_RSLT_FLAG == "0" && curcard.RSV_ONE_FLAG != "0"){
						tempFee = (Number(parseFloat(tempFee).toFixed(2)) + Number(parseFloat(allacc[i].AVAILABLEAMT).toFixed(2)));
					}
				}
			}
			$("#totalAmt").val(Math.abs(parseFloat(tempFee)).toFixed(2));
		}else{
			jAlert("请选择一条卡片信息！");
		}
	}
	function readCard(){
		$.messager.progress({text:"正在获取卡片信息，请稍后...."});
		cardmsg = getcardinfo();
		if(dealNull(cardmsg["card_No"]).length == 0){
			$.messager.progress("close");
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + cardmsg["errMsg"],"error");
			return;
		}
		$.messager.progress("close");
		$("#cardNo").val(cardmsg["card_No"]);
		$("#cardTrCount").val(cardmsg["recharge_Tr_Count"]);
		$("#cardAmt").val((parseFloat(isNaN(cardmsg["wallet_Amt"]) ? 0 : cardmsg["wallet_Amt"])/100).toFixed(2));
		query();
	}
	function saveBhkHjl(){
		if($("#totalAmt").val().replace(/\s/g,"") == ""){
			$.messager.alert("系统消息","金额不能为空！","error");
			return;
		}
		if(isNaN($("#totalAmt").val())){
			$.messager.alert("系统消息","金额格式不正确！","error");
			return;
		}
		var curcard =  $cardinfo.datagrid("getSelected");
		if(curcard){
			if(curcard.CARD_STATE != "9"){
				$.messager.alert("系统消息","老卡不是注销状态，不能进行换卡转钱包操作！","error");
				return;
			}
			var allacc = accinfo.window.getAllData();
			if(!allacc || allacc.length < 1){
				$.messager.alert("系统消息","老卡账户信息不存在，请仔细核对后，稍后重试！","error");
				return;
			}
			if((allacc[0]).BAL_RSLT_FLAG != "0"){
				$.messager.alert("系统消息","账户余额已返还，不能重复进行换卡转钱包！","error");
				return;
			}
			if(curcard.RSV_ONE_FLAG != "0"){
				var curdate = getDatabaseDate();
				if(curdate < (allacc[0]).FHRQ){
					$.messager.alert("系统消息","时间还未到达账户返还日期，请稍后进行操作！","error");
					return;
				}
			}
			$.messager.confirm("系统消息","您确定要进行换卡转钱包吗？" + "<br/>转账总金额：" + $("#totalAmt").val() ,function(is){
				if(is){
					$.messager.progress({text:"数据处理中，请稍后...."});
					$.post("cardService/cardServiceAction!saveBhkZzAshHjl.action",$("form").serialize()+ "&rec.cardNo=" + $("#cardNo").val() + "&cardAmt=" + $("#cardAmt").val(),function(data,status){
						if(status == "success"){
							if(data.status == "0"){
								$.messager.progress("close");
								$("#dealNo").val(data.dealNo);
								$.messager.progress({text:"正在写卡，请稍后...."});
								write_card(data.writecarddata);
							}else{
								$.messager.progress("close");
								$.messager.alert("系统消息",data.msg,"error");
							}
						}else{
							$.messager.progress("close");
							$.messager.alert("系统消息","请求出现错误，请稍后重试！","error");
						}
					},"json").error(function(){
						$.messager.progress("close");
						$.messager.alert("系统消息","请求出现错误，请稍后重试！","error");
					});
				}
			});
		}else{
			$.messager.alert("系统消息","请选择一条卡信息记录！","warning");
		}
	}
	function write_card(writecarddata){
		cardinfo = getcardinfo();
		if(judgeReadCardOk(cardinfo)){
			cycleNum0 = 0;
			wirtecard_recharge($("#cardNo").val(),writecarddata);
			cardinfo = getcardinfo();
			if(judgeReadCardOk(cardinfo)){
				if(Number(cardinfo["wallet_Amt"]) == getAmt()){
					$.messager.progress("close");
					$.messager.progress({text:"写卡成功，正在确认，请稍候..."});
					saveBhkZzConfirm();
				}else{
					cycleNum1++;
					if(cycleNum1 >= finalcyclenum){
						$.messager.progress("close");
						$.messager.progress({text:"写卡失败，正在撤销，请稍候..."});
						saveBhkZzCancel();
					}else{
						$.messager.progress("close");
						$.messager.alert("系统消息","换卡转钱包写卡出现错误，请拿起并重新放置好卡片，点击【确定】再次进行转账！","error",function(){
							$.messager.progress({text : "正在进行转账，请稍后...."});
							write_card(writecarddata);
						});
					}
				}
			}else{
				write_card_next(writecarddata);
			}
		}else{
			cycleNum0++;
			if(cycleNum0 >= finalcyclenum){
				saveBhkZzCancel();
			}else{
				$.messager.progress("close");
				$.messager.alert("系统消息","写卡前获取卡片信息出现错误，请拿起并重新放置好卡片，点击【确定】再次进行转账！0" + cycleNum1 ,"error",function(){
					$.messager.progress({text : "正在进行转账，请稍后...."});
					write_card(writecarddata);
				});
			}
		}
	}
	function write_card_next(writecarddata){
		cardinfo = getcardinfo();
		if(judgeReadCardOk(cardinfo)){
			cycleNum2 = 0;
			if(Number(cardinfo["wallet_Amt"]) == (Number($("#cardAmt").val()).mul100() + Number($("#totalAmt").val()).mul100())){
				saveBhkZzConfirm();
			}else{
				cycleNum1++;
				if(cycleNum1 >= finalcyclenum){
					saveBhkZzCancel();
				}else{
					$.messager.progress("close");
					$.messager.alert("系统消息","换卡转钱包写卡出现错误，请拿起并重新放置好卡片，点击【确定】再次进行转账！","error",function(){
						$.messager.progress({text : "正在进行转账，请稍后...."});
						write_card(writecarddata);
					});
				}
			}
		}else{
			cycleNum2++;
			if(cycleNum2 >= finalcyclenum){
				$.messager.progress("close");
				$.messager.alert("系统消息","写卡后获取卡片信息出现错误，请再次读卡确认是否写卡成功，并人工处理【灰记录】！","error",function(){
					$.messager.progress({text : "正在加载，请稍后...."});
					window.history.go(0);
				});
			}else{
				$.messager.progress("close");
				$.messager.alert("系统消息","写卡后获取卡片信息出现错误，请拿起并重新放置好卡片，点击【确定】再次进行转账！","error",function(){
					$.messager.progress({text : "正在进行换卡转钱包，请稍后...."});
					write_card_next(writecarddata);
				});
			}
		}
	}
	function saveBhkZzCancel(){
		$.post("cardService/cardServiceAction!saveBhkZzCz.action",{dealNo:$("#dealNo").val()},function(data,status){
			$.messager.progress("close");
			if(status == "success"){
				if(data.status == "0"){
					$.messager.alert("系统消息","换卡转钱包出现错误，请重新转账！","error",function(){
						$.messager.progress({text : "正在进行加载，请稍后...."});
						window.history.go(0);
					});
				}else{
					$.messager.alert("系统消息","换卡转钱包出现错误，冲正出现错误：" + data.msg + "，请人工取消【灰记录】！","error",function(){
						$.messager.progress({text : "正在进行加载，请稍后...."});
						window.history.go(0);
					});
				}
			}else{
				$.messager.alert("系统消息","换卡转钱包出现错误，冲正出现错误，请人工取消【灰记录】！","error",function(){
					$.messager.progress({text:"正在进行加载，请稍后...."});
					window.history.go(0);
				});
			}
		},"json").error(function(){
			$.messager.progress("close");
			$.messager.alert("系统消息","换卡转钱包出现错误，冲正出现错误，请人工取消【灰记录】！","error",function(){
				$.messager.progress({text : "正在进行加载，请稍后...."});
				window.history.go(0);
			});
		});
	}
	function saveBhkZzConfirm(){
		$.post("cardService/cardServiceAction!saveBhkZzConfirm.action",{dealNo:$("#dealNo").val()},function(data,status){
			if(status == "success"){
				$.messager.progress("close");
				if(data.status == "0"){
					showReport("换卡转钱包",$("#dealNo").val(),function(){
						window.history.go(0);
					});
				}else{
					$.messager.alert("系统消息","写卡成功，确认换卡转钱包灰记录出现错误：" + data.msg + "，请在打印凭证后人工确认【灰记录】！","error",function(){
						showReport("换卡转钱包",$("#dealNo").val(),function(){
							window.history.go(0);
						});
					});
				}
			}else{
				$.messager.progress("close");
				$.messager.alert("系统消息","写卡成功，确认换卡转钱包灰记录出现错误，请在打印凭证后人工确认【灰记录】！","error",function(){
					showReport("换卡转钱包",$("#dealNo").val(),function(){
						window.history.go(0);
					});
				});
			}		
		},"json").error(function(){
			if($("#dealNo").val() != ""){
				$.messager.progress("close");
				$.messager.alert("系统消息","写卡成功，确认换卡转钱包灰记录出现错误，请在打印凭证后人工确认【灰记录】！","error",function(){
					showReport("换卡转钱包",$("#dealNo").val(),function(){
						window.history.go(0);
					});
				});
			}else{
				$.messager.progress("close");
				$.messager.alert("系统消息","写卡成功，确认换卡转钱包灰记录出现错误，请人工确认【灰记录】！","error",function(){
					$.messager.progress({text : "正在进行加载，请稍后...."});
					window.location.href = window.location.href + "?mm_=" + Math.random();
				});
			}
		});
	}
	function judgeReadCardOk(obj){
		if(obj["card_No"] == ""){
			return false;
		}
		if(obj["card_No"] == undefined){
			return false;
		}
		if(typeof(obj["card_No"]) == "undefined"){
			return false;
		}
		if(obj["card_No"] == "undefined"){
			return false;
		}
		if(obj["card_No"] != $("#cardNo").val()){
			return false;
		}
		return true;
	}
	function getAmt(){
		return (Number(Number($("#cardAmt").val()).mul100()) + Number(Number($("#totalAmt").val()).mul100()));
	}
	function readIdCard2(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var certinfo = getcertinfo();
		if(dealNull(certinfo["cert_No"]).length < 15){			
			$.messager.progress("close");
			return;
		}
		$.messager.progress("close");
		$("#agtCertType").combobox("setValue","<%=com.erp.util.Constants.CERT_TYPE_SFZ%>");
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
<n:initpage title="换卡转钱包操作！<span style='color:red;font-weight:600;'>注意：</span>1、只有换卡的记录才能进行换卡转钱包；2、换卡前老卡是好卡时立即可转，坏卡需等待指定工作日后可转；">
	<n:center>
	  	<div id="tb">
			<table class="tablegrid">
				<tr>
					<tr>
						<td class="tableleft">卡号：</td>
						<td class="tableright"><input name="cardNo"  class="textinput" id="cardNo" type="text" readonly="readonly"/></td>
						<td class="tableleft">卡余额：</td>
						<td class="tableright"><input id="cardAmt" type="text" class="textinput" name="cardAmt" style="width:174px;" readonly="readonly"/></td>
						<td class="tableright">
							<a data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCard()">读卡</a>
							<a data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							<a data-options="plain:false,iconCls:'icon-ok'" href="javascript:void(0);" class="easyui-linkbutton" onclick="saveBhkHjl()">确定</a>
						</td>
				</tr>
			</table>
		</div>
  		<table id="cardinfo" title="老卡卡片信息" style="height:150px;"></table>
	</n:center>
	<div data-options="region:'south',split:false,border:true" style="height:300px; width:auto;text-align:center;overflow:hidden;border-bottom:none;border-left:none;">
		<div style="width:100%;display:none;" id="accinfodiv" class="datagrid-toolbar">
  			<h3 class="subtitle">账户信息</h3>
  			<iframe name="accinfo" id="accinfo"  width="100%" frameborder="0" height="56"></iframe>
		</div>
		<div style="width:100%;height:100%">
			<form id="form" method="post" class="datagrid-toolbar" style="width:100%;height:100%">
				<input name="rec.cardTrCount" id="cardTrCount" value="0" type="hidden" />
				<input name="dealNo" id="dealNo" type="hidden" />
				<h3 class="subtitle">代理人信息</h3>
				<table class="tablegrid" style="width:100%;">
					<tr>
						<th class="tableleft">转账总金额：</th>
						<td class="tableright"><input name="totalAmt" id="totalAmt" value="0" class="textinput easyui-validatebox" type="text" required="required"  readonly="readonly"/><span style="color:red;margin-left:10px;font-size:9px;">单位：元</span></td>
						<th class="tableleft">代理人证件类型：</th>
						<td class="tableright"><input id="agtCertType" type="text" class="easyui-combobox  easyui-validatebox" name="rec.agtCertType" value="1" style="width:174px;"/> </td>
						<th class="tableleft">代理人证件号码：</th>
						<td class="tableright"><input name="rec.agtCertNo"  class="textinput easyui-validatebox" id="agtCertNo" type="text" validtype="idcard" maxlength="18"/></td>
					</tr>
					<tr>
						<th class="tableleft">代理人姓名：</th>
						<td class="tableright"><input name="rec.agtName" id="agtName" type="text" class="textinput easyui-validatebox" maxlength="30"/></td>
				 		<th class="tableleft">代理人联系电话：</th>
						<td class="tableright"><input name="rec.agtTelNo" id="agtTelNo" type="text" class="textinput easyui-validatebox" validtype="mobile" maxlength="11" /></td>
						<td class="tableright" colspan="2">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readSMK2()">读市民卡</a>
							<a data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard2()">读身份证</a>
						</td>
					</tr>
			   </table>
		    </form>	
	    </div>		
    </div>
</n:initpage>